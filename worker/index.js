// Cloudflare Worker – Social + Store + Calls Backend
// Auth: JWT (Bearer)
// DB: env.db1 (D1)

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const path = url.pathname;
    const method = request.method;

    /* ============================================
       BLOCK 1 — Utilities
    ============================================ */

    const json = (data, status = 200) =>
      new Response(JSON.stringify(data), {
        status,
        headers: { "Content-Type": "application/json" },
      });

    const getBody = async () => {
      try {
        return await request.json();
      } catch {
        return {};
      }
    };

    const notFound = () => json({ error: "Not found" }, 404);

    const encoder = new TextEncoder();

    /* ============================================
       BLOCK 2 — JWT Auth System
    ============================================ */

    async function signJWT(payload, secret, expiresInSeconds = 86400) {
      const header = { alg: "HS256", typ: "JWT" };
      const now = Math.floor(Date.now() / 1000);
      const fullPayload = { ...payload, iat: now, exp: now + expiresInSeconds };

      const base64url = (obj) =>
        btoa(JSON.stringify(obj))
          .replace(/=/g, "")
          .replace(/\+/g, "-")
          .replace(/\//g, "_");

      const headerPart = base64url(header);
      const payloadPart = base64url(fullPayload);
      const data = `${headerPart}.${payloadPart}`;

      const key = await crypto.subtle.importKey(
        "raw",
        encoder.encode(secret),
        { name: "HMAC", hash: "SHA-256" },
        false,
        ["sign"]
      );

      const signature = await crypto.subtle.sign(
        "HMAC",
        key,
        encoder.encode(data)
      );

      const signatureBase64 = btoa(
        String.fromCharCode(...new Uint8Array(signature))
      )
        .replace(/=/g, "")
        .replace(/\+/g, "-")
        .replace(/\//g, "_");

      return `${data}.${signatureBase64}`;
    }

    async function verifyJWT(token, secret) {
      try {
        const [headerPart, payloadPart, signaturePart] = token.split(".");
        if (!headerPart || !payloadPart || !signaturePart) return null;

        const data = `${headerPart}.${payloadPart}`;

        const key = await crypto.subtle.importKey(
          "raw",
          encoder.encode(secret),
          { name: "HMAC", hash: "SHA-256" },
          false,
          ["verify"]
        );

        const signatureBytes = Uint8Array.from(
          atob(signaturePart.replace(/-/g, "+").replace(/_/g, "/")),
          (c) => c.charCodeAt(0)
        );

        const valid = await crypto.subtle.verify(
          "HMAC",
          key,
          signatureBytes,
          encoder.encode(data)
        );

        if (!valid) return null;

        const payloadJson = atob(
          payloadPart.replace(/-/g, "+").replace(/_/g, "/")
        );
        const payload = JSON.parse(payloadJson);

        const now = Math.floor(Date.now() / 1000);
        if (payload.exp && payload.exp < now) return null;

        return payload;
      } catch {
        return null;
      }
    }

    /* ============================================
       BLOCK 3 — ID Helpers (hex16 + public_id)
    ============================================ */

    function generateHex16() {
      const bytes = crypto.getRandomValues(new Uint8Array(8)); // 8 bytes = 16 hex chars
      return [...bytes].map((b) => b.toString(16).padStart(2, "0")).join("");
    }

    function generatePublicId(prefix, userHex) {
      const postHex = generateHex16();
      return {
        postHex,
        publicId: `${prefix}${postHex}-u${userHex}`,
      };
    }

    /* ============================================
       BLOCK 4 — Auth Helpers
    ============================================ */

    async function getAuthUser() {
      const auth = request.headers.get("Authorization") || "";
      const token = auth.startsWith("Bearer ") ? auth.slice(7) : null;
      if (!token) return null;
      return await verifyJWT(token, env.JWT_SECRET);
    }

    async function requireAuth() {
      const user = await getAuthUser();
      if (!user) return { error: json({ error: "Unauthorized" }, 401), user: null };
      if (user.banned) return { error: json({ error: "Banned user" }, 403), user: null };
      return { error: null, user };
    }

    async function requireRole(roles) {
      const { error, user } = await requireAuth();
      if (error) return { error, user: null };
      if (!roles.includes(user.role)) {
        return { error: json({ error: "Forbidden" }, 403), user: null };
      }
      return { error: null, user };
    }

    async function getUserById(id) {
      return await env.db1
        .prepare(
          "SELECT id, username, role, banned, user_hex_id FROM users WHERE id = ?"
        )
        .bind(id)
        .first();
    }

    async function getUserByUsername(username) {
      return await env.db1
        .prepare(
          "SELECT id, username, role, banned, user_hex_id FROM users WHERE username = ?"
        )
        .bind(username)
        .first();
    }

    /* ============================================
       BLOCK 5 — Wallet + Pricing Helpers
    ============================================ */

    async function ensureWallet(env, userId) {
      const row = await env.db1
        .prepare("SELECT balance FROM wallets WHERE user_id = ?")
        .bind(userId)
        .first();
      if (!row) {
        await env.db1
          .prepare(
            `INSERT INTO wallets (user_id, balance, created_at, updated_at)
             VALUES (?, 0, datetime('now'), datetime('now'))`
          )
          .bind(userId)
          .run();
        return 0;
      }
      return row.balance;
    }

    async function getUserBalance(env, userId) {
      const row = await env.db1
        .prepare("SELECT balance FROM wallets WHERE user_id = ?")
        .bind(userId)
        .first();
      return row ? row.balance : 0;
    }

    async function setUserBalance(env, userId, newBalance) {
      await env.db1
        .prepare(
          `INSERT INTO wallets (user_id, balance, created_at, updated_at)
           VALUES (?, ?, datetime('now'), datetime('now'))
           ON CONFLICT(user_id) DO UPDATE SET balance = excluded.balance, updated_at = datetime('now')`
        )
        .bind(userId, newBalance)
        .run();
    }

    async function addTransaction(env, userId, amount, type, featureKey) {
      await env.db1
        .prepare(
          `INSERT INTO transactions (user_id, amount, type, feature_key, created_at)
           VALUES (?, ?, ?, ?, datetime('now'))`
        )
        .bind(userId, amount, type, featureKey)
        .run();
    }

    async function getFeaturePrice(env, featureKey) {
      const row = await env.db1
        .prepare("SELECT price FROM feature_prices WHERE feature_key = ?")
        .bind(featureKey)
        .first();
      if (!row) throw new Error(`Missing price for feature: ${featureKey}`);
      return row.price;
    }

    async function chargeUser(env, userId, amount, featureKey) {
      await ensureWallet(env, userId);
      const balance = await getUserBalance(env, userId);
      if (balance < amount) throw new Error("INSUFFICIENT_BALANCE");
      const newBalance = balance - amount;
      await setUserBalance(env, userId, newBalance);
      await addTransaction(env, userId, -amount, "spend", featureKey);
      return newBalance;
    }

    async function addTempCallCharge(env, callId, userId, amount) {
      await env.db1
        .prepare(
          `INSERT INTO call_temp_wallet (call_id, user_id, amount, created_at)
           VALUES (?, ?, ?, datetime('now'))`
        )
        .bind(callId, userId, amount)
        .run();
    }

    async function getCallGuestsCount(env, callId, creatorId) {
      const row = await env.db1
        .prepare(
          `SELECT COUNT(*) AS cnt
           FROM call_participants
           WHERE call_id = ?`
        )
        .bind(callId)
        .first();
      const total = row ? row.cnt : 0;
      return Math.max(total - 1, 0);
    }

    async function getCallTotalTempAmount(env, callId) {
      const row = await env.db1
        .prepare(
          `SELECT COALESCE(SUM(amount), 0) AS total
           FROM call_temp_wallet
           WHERE call_id = ?`
        )
        .bind(callId)
        .first();
      return row ? row.total : 0;
    }

    /* ============================================
       BLOCK 6 — Health
    ============================================ */

    if (path === "/" && method === "GET") {
      return json({ status: "ok", message: "API is running" });
    }

    /* ============================================
       BLOCK 7 — AUTH (Register / Login / Me)
    ============================================ */

    // POST /auth/register
    if (path === "/auth/register" && method === "POST") {
      const body = await getBody();
      const { username, password } = body;

      if (!username || !password) {
        return json({ error: "username and password required" }, 400);
      }

      const countRow = await env.db1
        .prepare("SELECT COUNT(*) AS c FROM users")
        .first();
      const isFirstUser = (countRow?.c || 0) === 0;
      const role = isFirstUser ? "owner" : "user";

      const userHex = generateHex16();

      try {
        await env.db1
          .prepare(
            "INSERT INTO users (username, password, role, banned, user_hex_id) VALUES (?, ?, ?, 0, ?)"
          )
          .bind(username, password, role, userHex)
          .run();

        const user = await getUserByUsername(username);

        if (user) {
          await ensureWallet(env, user.id);
        }

        return json({ success: true, role });
      } catch (e) {
        return json({ error: "Username already exists" }, 400);
      }
    }

    // POST /auth/login
    if (path === "/auth/login" && method === "POST") {
      const body = await getBody();
      const { username, password } = body;

      if (!username || !password) {
        return json({ error: "username and password required" }, 400);
      }

      const user = await env.db1
        .prepare(
          "SELECT id, username, role, banned, user_hex_id FROM users WHERE username = ? AND password = ?"
        )
        .bind(username, password)
        .first();

      if (!user) return json({ error: "Invalid credentials" }, 401);
      if (user.banned) return json({ error: "User is banned" }, 403);

      const token = await signJWT(
        {
          id: user.id,
          username: user.username,
          role: user.role,
          banned: user.banned,
          user_hex_id: user.user_hex_id,
        },
        env.JWT_SECRET
      );

      return json({
        success: true,
        token,
        user: {
          id: user.id,
          username: user.username,
          role: user.role,
          banned: user.banned,
          user_hex_id: user.user_hex_id,
        },
      });
    }

    // GET /auth/me
    if (path === "/auth/me" && method === "GET") {
      const { error, user } = await requireAuth();
      if (error) return error;
      return json({ user });
    }

    /* ============================================
       BLOCK 8 — Roles Management
    ============================================ */

    // POST /admin/role
    if (path === "/admin/role" && method === "POST") {
      const { error, user } = await requireRole(["owner", "admin"]);
      if (error) return error;

      const body = await getBody();
      const { user_id, new_role } = body;

      if (!user_id || !new_role) {
        return json({ error: "user_id and new_role required" }, 400);
      }

      const target = await getUserById(user_id);
      if (!target) return json({ error: "User not found" }, 404);

      if (target.role === "owner") {
        return json({ error: "Cannot change owner role" }, 403);
      }

      if (user.role === "admin" && new_role === "owner") {
        return json({ error: "Admin cannot assign owner role" }, 403);
      }

      await env.db1
        .prepare("UPDATE users SET role = ? WHERE id = ?")
        .bind(new_role, user_id)
        .run();

      return json({ success: true });
    }

    /* ============================================
       BLOCK 9 — Ban System
    ============================================ */

    // POST /admin/ban/:userId
    if (path.startsWith("/admin/ban/") && method === "POST") {
      const { error, user } = await requireRole(["owner", "admin"]);
      if (error) return error;

      const parts = path.split("/");
      const targetId = parseInt(parts[3] || "0", 10);
      if (!targetId) return json({ error: "Invalid user id" }, 400);

      const target = await getUserById(targetId);
      if (!target) return json({ error: "User not found" }, 404);

      if (target.role === "owner") {
        return json({ error: "Cannot ban owner" }, 403);
      }

      await env.db1
        .prepare("UPDATE users SET banned = 1 WHERE id = ?")
        .bind(targetId)
        .run();

      return json({ success: true });
    }

    // POST /admin/unban/:userId
    if (path.startsWith("/admin/unban/") && method === "POST") {
      const { error, user } = await requireRole(["owner", "admin"]);
      if (error) return error;

      const parts = path.split("/");
      const targetId = parseInt(parts[3] || "0", 10);
      if (!targetId) return json({ error: "Invalid user id" }, 400);

      const target = await getUserById(targetId);
      if (!target) return json({ error: "User not found" }, 404);

      await env.db1
        .prepare("UPDATE users SET banned = 0 WHERE id = ?")
        .bind(targetId)
        .run();

      return json({ success: true });
    }

    /* ============================================
       BLOCK 10 — Posts System (personal + merchant)
    ============================================ */

    async function canUserPost(user) {
      if (user.role === "moderator") return false;
      if (user.banned) return false;
      return true;
    }

    // POST /posts/personal
    if (path === "/posts/personal" && method === "POST") {
      const { error, user } = await requireAuth();
      if (error) return error;

      if (!(await canUserPost(user))) {
        return json({ error: "This role cannot create posts" }, 403);
      }

      const body = await getBody();
      const { cid } = body;
      if (!cid) return json({ error: "cid required" }, 400);

      let dbUser = await getUserById(user.id);
      if (!dbUser.user_hex_id) {
        const newHex = generateHex16();
        await env.db1
          .prepare("UPDATE users SET user_hex_id = ? WHERE id = ?")
          .bind(newHex, user.id)
          .run();
        dbUser = await getUserById(user.id);
      }

      const { postHex, publicId } = generatePublicId("p", dbUser.user_hex_id);

      await env.db1
        .prepare(
          `INSERT INTO posts_personal (public_id, post_hex_id, owner_id, cid, type, hidden, created_at)
           VALUES (?, ?, ?, ?, ?, 0, datetime('now'))`
        )
        .bind(publicId, postHex, user.id, cid, "personal")
        .run();

      return json({ success: true, public_id: publicId });
    }

    // POST /posts/merchant
    if (path === "/posts/merchant" && method === "POST") {
      const { error, user } = await requireAuth();
      if (error) return error;

      if (!(await canUserPost(user))) {
        return json({ error: "This role cannot create posts" }, 403);
      }

      if (!["seller", "admin", "owner"].includes(user.role)) {
        return json({ error: "Only seller/admin/owner can create merchant posts" }, 403);
      }

      const body = await getBody();
      const { cid, product_id } = body;
      if (!cid || !product_id) {
        return json({ error: "cid and product_id required" }, 400);
      }

      let dbUser = await getUserById(user.id);
      if (!dbUser.user_hex_id) {
        const newHex = generateHex16();
        await env.db1
          .prepare("UPDATE users SET user_hex_id = ? WHERE id = ?")
          .bind(newHex, user.id)
          .run();
        dbUser = await getUserById(user.id);
      }

      const { postHex, publicId } = generatePublicId("m", dbUser.user_hex_id);

      await env.db1
        .prepare(
          `INSERT INTO posts_product (public_id, post_hex_id, owner_id, product_id, cid, type, hidden, created_at)
           VALUES (?, ?, ?, ?, ?, ?, 0, datetime('now'))`
        )
        .bind(publicId, postHex, user.id, product_id, cid, "product")
        .run();

      return json({ success: true, public_id: publicId });
    }

    // GET /posts/home
    if (path === "/posts/home" && method === "GET") {
      const personal = await env.db1
        .prepare(
          `SELECT 'personal' AS kind, p.public_id, p.cid, p.created_at, u.username, u.user_hex_id
           FROM posts_personal p
           JOIN users u ON p.owner_id = u.id
           WHERE p.hidden = 0
           ORDER BY p.id DESC
           LIMIT 50`
        )
        .all();

      const merchant = await env.db1
        .prepare(
          `SELECT 'merchant' AS kind, p.public_id, p.cid, p.created_at, u.username, u.user_hex_id
           FROM posts_product p
           JOIN users u ON p.owner_id = u.id
           WHERE p.hidden = 0
           ORDER BY p.id DESC
           LIMIT 50`
        )
        .all();

      const list = [
        ...(personal.results || []),
        ...(merchant.results || []),
      ].sort((a, b) => (a.created_at < b.created_at ? 1 : -1));

      return json({ posts: list });
    }

    // GET /posts/mine
    if (path === "/posts/mine" && method === "GET") {
      const { error, user } = await requireAuth();
      if (error) return error;

      const personal = await env.db1
        .prepare(
          `SELECT 'personal' AS kind, public_id, cid, created_at
           FROM posts_personal
           WHERE owner_id = ?
           ORDER BY id DESC`
        )
        .bind(user.id)
        .all();

      const merchant = await env.db1
        .prepare(
          `SELECT 'merchant' AS kind, public_id, cid, created_at
           FROM posts_product
           WHERE owner_id = ?
           ORDER BY id DESC`
        )
        .bind(user.id)
        .all();

      return json({
        posts: [
          ...(personal.results || []),
          ...(merchant.results || []),
        ],
      });
    }

    // GET /post/:public_id
    if (path.startsWith("/post/") && method === "GET") {
      const publicId = decodeURIComponent(path.split("/")[2] || "");
      if (!publicId) return json({ error: "Invalid public_id" }, 400);

      const prefix = publicId[0];
      let row = null;

      if (prefix === "p") {
        row = await env.db1
          .prepare(
            `SELECT 'personal' AS kind, p.*, u.username, u.user_hex_id
             FROM posts_personal p
             JOIN users u ON p.owner_id = u.id
             WHERE p.public_id = ?`
          )
          .bind(publicId)
          .first();
      } else if (prefix === "m") {
        row = await env.db1
          .prepare(
            `SELECT 'merchant' AS kind, p.*, u.username, u.user_hex_id
             FROM posts_product p
             JOIN users u ON p.owner_id = u.id
             WHERE p.public_id = ?`
          )
          .bind(publicId)
          .first();
      } else {
        return json({ error: "Invalid public_id prefix" }, 400);
      }

      if (!row) return json({ error: "Post not found" }, 404);
      if (row.hidden) return json({ error: "Post hidden" }, 403);

      return json({ post: row });
    }

    // POST /post/:public_id/hide
    if (path.startsWith("/post/") && path.endsWith("/hide") && method === "POST") {
      const { error, user } = await requireAuth();
      if (error) return error;

      const parts = path.split("/");
      const publicId = decodeURIComponent(parts[2] || "");
      if (!publicId) return json({ error: "Invalid public_id" }, 400);

      const prefix = publicId[0];
      let row = null;
      let table = null;

      if (prefix === "p") {
        table = "posts_personal";
        row = await env.db1
          .prepare(`SELECT * FROM posts_personal WHERE public_id = ?`)
          .bind(publicId)
          .first();
      } else if (prefix === "m") {
        table = "posts_product";
        row = await env.db1
          .prepare(`SELECT * FROM posts_product WHERE public_id = ?`)
          .bind(publicId)
          .first();
      } else {
        return json({ error: "Invalid public_id prefix" }, 400);
      }

      if (!row) return json({ error: "Post not found" }, 404);

      const canHide =
        row.owner_id === user.id ||
        ["owner", "admin", "moderator"].includes(user.role);

      if (!canHide) return json({ error: "Forbidden" }, 403);

      await env.db1
        .prepare(`UPDATE ${table} SET hidden = 1 WHERE public_id = ?`)
        .bind(publicId)
        .run();

      return json({ success: true });
    }

    /* ============================================
       BLOCK 11 — Reports System
    ============================================ */

    // POST /reports
    if (path === "/reports" && method === "POST") {
      const { error, user } = await requireAuth();
      if (error) return error;

      const body = await getBody();
      const { post_public_id, reason } = body;
      if (!post_public_id || !reason) {
        return json({ error: "post_public_id and reason required" }, 400);
      }

      const prefix = post_public_id[0];
      let postType = null;

      if (prefix === "p") postType = "personal";
      else if (prefix === "m") postType = "product";
      else return json({ error: "Invalid public_id prefix" }, 400);

      await env.db1
        .prepare(
          `INSERT INTO reports (post_type, post_public_id, reporter_id, reason, status)
           VALUES (?, ?, ?, ?, 'pending')`
        )
        .bind(postType, post_public_id, user.id, reason)
        .run();

      return json({ success: true });
    }

    // GET /admin/reports
    if (path === "/admin/reports" && method === "GET") {
      const { error, user } = await requireRole(["owner", "admin", "moderator"]);
      if (error) return error;

      const reports = await env.db1
        .prepare(
          `SELECT r.*
           FROM reports r
           ORDER BY r.id DESC`
        )
        .all();

      return json({ reports: reports.results || [] });
    }

    // POST /admin/reports/:id/resolve
    if (path.startsWith("/admin/reports/") && path.endsWith("/resolve") && method === "POST") {
      const { error, user } = await requireRole(["owner", "admin", "moderator"]);
      if (error) return error;

      const parts = path.split("/");
      const reportId = parseInt(parts[3] || "0", 10);
      if (!reportId) return json({ error: "Invalid report id" }, 400);

      await env.db1
        .prepare("UPDATE reports SET status = 'resolved' WHERE id = ?")
        .bind(reportId)
        .run();

      return json({ success: true });
    }

    /* ============================================
       BLOCK 12 — Store / Seller System
    ============================================ */

    // POST /store/upgrade
    if (path === "/store/upgrade" && method === "POST") {
      const { error, user } = await requireAuth();
      if (error) return error;

      const body = await getBody();
      const { name, description } = body;
      if (!name) return json({ error: "Store name required" }, 400);

      const existing = await env.db1
        .prepare("SELECT * FROM stores WHERE owner_id = ?")
        .bind(user.id)
        .first();

      if (existing) {
        if (user.role === "user") {
          await env.db1
            .prepare("UPDATE users SET role = 'seller' WHERE id = ?")
            .bind(user.id)
            .run();
        }
        return json({ success: true, store: existing });
      }

      await env.db1
        .prepare(
          `INSERT INTO stores (owner_id, name, description, created_at)
           VALUES (?, ?, ?, datetime('now'))`
        )
        .bind(user.id, name, description || "")
        .run();

      await env.db1
        .prepare("UPDATE users SET role = 'seller' WHERE id = ?")
        .bind(user.id)
        .run();

      const store = await env.db1
        .prepare("SELECT * FROM stores WHERE owner_id = ?")
        .bind(user.id)
        .first();

      return json({ success: true, store });
    }

    // GET /store/mine
    if (path === "/store/mine" && method === "GET") {
      const { error, user } = await requireAuth();
      if (error) return error;

      const store = await env.db1
        .prepare("SELECT * FROM stores WHERE owner_id = ?")
        .bind(user.id)
        .first();

      return json({ store: store || null });
    }

    // POST /store/products
    if (path === "/store/products" && method === "POST") {
      const { error, user } = await requireRole(["seller", "admin", "owner"]);
      if (error) return error;

      const body = await getBody();
      const { name, description, price, stock } = body;
      if (!name || price == null || stock == null) {
        return json({ error: "name, price, stock required" }, 400);
      }

      const store = await env.db1
        .prepare("SELECT * FROM stores WHERE owner_id = ?")
        .bind(user.id)
        .first();

      if (!store) return json({ error: "Store not found" }, 404);

      await env.db1
        .prepare(
          `INSERT INTO products (store_id, name, description, price, stock, hidden, created_at)
           VALUES (?, ?, ?, ?, ?, 0, datetime('now'))`
        )
        .bind(store.id, name, description || "", price, stock)
        .run();

      return json({ success: true });
    }

    // GET /store/products/mine
    if (path === "/store/products/mine" && method === "GET") {
      const { error, user } = await requireRole(["seller", "admin", "owner"]);
      if (error) return error;

      const store = await env.db1
        .prepare("SELECT * FROM stores WHERE owner_id = ?")
        .bind(user.id)
        .first();

      if (!store) return json({ products: [] });

      const products = await env.db1
        .prepare(
          `SELECT * FROM products
           WHERE store_id = ? AND hidden = 0
           ORDER BY id DESC`
        )
        .bind(store.id)
        .all();

      return json({ products: products.results || [] });
    }

    // GET /store/products
    if (path === "/store/products" && method === "GET") {
      const products = await env.db1
        .prepare(
          `SELECT p.*, s.name AS store_name
           FROM products p
           JOIN stores s ON p.store_id = s.id
           WHERE p.hidden = 0
           ORDER BY p.id DESC`
        )
        .all();

      return json({ products: products.results || [] });
    }

    // POST /products/:id/hide
    if (path.startsWith("/products/") && path.endsWith("/hide") && method === "POST") {
      const { error, user } = await requireAuth();
      if (error) return error;

      const parts = path.split("/");
      const productId = parseInt(parts[2] || "0", 10);
      if (!productId) return json({ error: "Invalid product id" }, 400);

      const product = await env.db1
        .prepare(
          `SELECT p.*, s.owner_id AS store_owner_id
           FROM products p
           JOIN stores s ON p.store_id = s.id
           WHERE p.id = ?`
        )
        .bind(productId)
        .first();

      if (!product) return json({ error: "Product not found" }, 404);

      const canHide =
        product.store_owner_id === user.id ||
        ["owner", "admin", "moderator"].includes(user.role);

      if (!canHide) return json({ error: "Forbidden" }, 403);

      await env.db1
        .prepare("UPDATE products SET hidden = 1 WHERE id = ?")
        .bind(productId)
        .run();

      return json({ success: true });
    }

    /* ============================================
       BLOCK 13 — Calls System (start/add/extend/end)
    ============================================ */

    // POST /calls/start
    if (path === "/calls/start" && method === "POST") {
      try {
        const { error, user } = await requireAuth();
        if (error) return error;

        const body = await getBody();
        const callType = body.call_type;

        if (callType !== "voice" && callType !== "video") {
          return json({ error: "INVALID_CALL_TYPE" }, 400);
        }

        const featureKey =
          callType === "voice" ? "call_voice_5min" : "call_video_5min";

        const pricePerGuest = await getFeaturePrice(env, featureKey);

        const guests = 1;
        const totalPrice = pricePerGuest * guests;

        await chargeUser(env, user.id, totalPrice, featureKey);

        const now = new Date();
        const expires = new Date(now.getTime() + 5 * 60 * 1000);

        await env.db1
          .prepare(
            `INSERT INTO calls (creator_id, call_type, start_time, expires_at, total_price)
             VALUES (?, ?, ?, ?, ?)`
          )
          .bind(
            user.id,
            callType,
            now.toISOString(),
            expires.toISOString(),
            totalPrice
          )
          .run();

        const callRow = await env.db1
          .prepare(
            `SELECT id FROM calls
             WHERE creator_id = ? AND start_time = ?
             ORDER BY id DESC LIMIT 1`
          )
          .bind(user.id, now.toISOString())
          .first();

        const callId = callRow?.id;

        await env.db1
          .prepare(
            `INSERT INTO call_participants (call_id, user_id, joined_at)
             VALUES (?, ?, datetime('now'))`
          )
          .bind(callId, user.id)
          .run();

        await addTempCallCharge(env, callId, user.id, totalPrice);

        return json({
          success: true,
          call_id: callId,
          call_type: callType,
          expires_at: expires.toISOString(),
          charged: totalPrice,
        });
      } catch (e) {
        return json({ success: false, error: e.message }, 400);
      }
    }

    // POST /calls/add-participant
    if (path === "/calls/add-participant" && method === "POST") {
      try {
        const { error, user } = await requireAuth();
        if (error) return error;

        const body = await getBody();
        const { call_id, new_user_id } = body;

        if (!call_id || !new_user_id) {
          return json({ error: "call_id and new_user_id required" }, 400);
        }

        const call = await env.db1
          .prepare(
            `SELECT id, creator_id, call_type, expires_at, total_price
             FROM calls
             WHERE id = ?`
          )
          .bind(call_id)
          .first();

        if (!call) return json({ error: "CALL_NOT_FOUND" }, 404);
        if (call.creator_id !== user.id) {
          return json({ error: "NOT_CALL_OWNER" }, 403);
        }

        const now = new Date();
        if (call.expires_at && new Date(call.expires_at) < now) {
          return json({ error: "CALL_EXPIRED" }, 400);
        }

        const featureKey =
          call.call_type === "voice"
            ? "call_voice_5min"
            : "call_video_5min";

        const pricePerGuest = await getFeaturePrice(env, featureKey);
        const extraPrice = pricePerGuest * 1;

        await chargeUser(env, user.id, extraPrice, featureKey);

        await env.db1
          .prepare(
            `INSERT INTO call_participants (call_id, user_id, joined_at)
             VALUES (?, ?, datetime('now'))`
          )
          .bind(call_id, new_user_id)
          .run();

        const newTotal = (call.total_price || 0) + extraPrice;

        await env.db1
          .prepare(
            `UPDATE calls
             SET total_price = ?
             WHERE id = ?`
          )
          .bind(newTotal, call_id)
          .run();

        await addTempCallCharge(env, call_id, user.id, extraPrice);

        return json({
          success: true,
          call_id,
          extra_charged: extraPrice,
          total_price: newTotal,
        });
      } catch (e) {
        return json({ success: false, error: e.message }, 400);
      }
    }

    // POST /calls/extend
    if (path === "/calls/extend" && method === "POST") {
      try {
        const { error, user } = await requireAuth();
        if (error) return error;

        const body = await getBody();
        const { call_id, duration } = body;

        if (!call_id || !duration) {
          return json({ error: "call_id and duration required" }, 400);
        }

        const call = await env.db1
          .prepare(
            `SELECT id, creator_id, call_type, expires_at, total_price
             FROM calls
             WHERE id = ?`
          )
          .bind(call_id)
          .first();

        if (!call) return json({ error: "CALL_NOT_FOUND" }, 404);
        if (call.creator_id !== user.id) {
          return json({ error: "NOT_CALL_OWNER" }, 403);
        }

        const allowed = ["15", "30", "60"];
        if (!allowed.includes(String(duration))) {
          return json({ error: "INVALID_DURATION" }, 400);
        }

        const featureKey =
          call.call_type === "voice"
            ? `call_voice_${duration}min`
            : `call_video_${duration}min`;

        const pricePerGuest = await getFeaturePrice(env, featureKey);

        const guests = await getCallGuestsCount(env, call_id, call.creator_id);

        const totalPrice = pricePerGuest * guests;

        if (totalPrice > 0) {
          await chargeUser(env, user.id, totalPrice, featureKey);
        }

        const currentExpires = call.expires_at
          ? new Date(call.expires_at)
          : new Date();
        const extraMs = parseInt(duration, 10) * 60 * 1000;
        const newExpires = new Date(currentExpires.getTime() + extraMs);

        const newTotal = (call.total_price || 0) + totalPrice;

        await env.db1
          .prepare(
            `UPDATE calls
             SET expires_at = ?, total_price = ?
             WHERE id = ?`
          )
          .bind(newExpires.toISOString(), newTotal, call_id)
          .run();

        if (totalPrice > 0) {
          await addTempCallCharge(env, call_id, user.id, totalPrice);
        }

        return json({
          success: true,
          call_id,
          added_duration: duration,
          extra_charged: totalPrice,
          total_price: newTotal,
          expires_at: newExpires.toISOString(),
        });
      } catch (e) {
        return json({ success: false, error: e.message }, 400);
      }
    }

    // POST /calls/end
    if (path === "/calls/end" && method === "POST") {
      try {
        const { error, user } = await requireAuth();
        if (error) return error;

        const body = await getBody();
        const { call_id } = body;

        if (!call_id) return json({ error: "call_id required" }, 400);

        const call = await env.db1
          .prepare(
            `SELECT id, creator_id
             FROM calls
             WHERE id = ?`
          )
          .bind(call_id)
          .first();

        if (!call) return json({ error: "CALL_NOT_FOUND" }, 404);
        if (call.creator_id !== user.id) {
          return json({ error: "NOT_CALL_OWNER" }, 403);
        }

        const now = new Date();

        await env.db1
          .prepare(
            `UPDATE calls
             SET end_time = ?
             WHERE id = ?`
          )
          .bind(now.toISOString(), call_id)
          .run();

        const totalTemp = await getCallTotalTempAmount(env, call_id);

        const ownerAccountId = 1; // adjust to your owner user id

        await ensureWallet(env, ownerAccountId);
        const ownerBalance = await getUserBalance(env, ownerAccountId);
        const newOwnerBalance = ownerBalance + totalTemp;

        await setUserBalance(env, ownerAccountId, newOwnerBalance);
        await addTransaction(env, ownerAccountId, totalTemp, "payout", "call_payout");

        return json({
          success: true,
          call_id,
          total_collected: totalTemp,
        });
      } catch (e) {
        return json({ success: false, error: e.message }, 400);
      }
    }

    /* ============================================
       BLOCK 14 — Call History
    ============================================ */

    // GET /calls/history
    if (path === "/calls/history" && method === "GET") {
      try {
        const { error, user } = await requireAuth();
        if (error) return error;

        const calls = await env.db1
          .prepare(
            `SELECT 
              id,
              call_type,
              start_time,
              end_time,
              total_price
             FROM calls
             WHERE creator_id = ?
             ORDER BY start_time DESC`
          )
          .bind(user.id)
          .all();

        const history = [];

        for (const call of calls.results || []) {
          const participants = await env.db1
            .prepare(
              `SELECT u.id, u.username
               FROM call_participants cp
               JOIN users u ON u.id = cp.user_id
               WHERE cp.call_id = ?`
            )
            .bind(call.id)
            .all();

          const names = (participants.results || []).map((p) => p.username);
          const duration = call.end_time
            ? Math.floor(
                (new Date(call.end_time) - new Date(call.start_time)) / 60000
              )
            : 0;

          history.push({
            call_id: call.id,
            call_type: call.call_type,
            participants: (participants.results || []).length,
            names,
            total_price: call.total_price,
            duration,
            start_time: call.start_time,
            end_time: call.end_time,
          });
        }

        return json({
          success: true,
          history,
        });
      } catch (e) {
        return json({ success: false, error: e.message }, 400);
      }
    }

    /* ============================================
       BLOCK 15 — Moderator Dashboard
    ============================================ */

    // GET /moderator/dashboard
    if (path === "/moderator/dashboard" && method === "GET") {
      const { error, user } = await requireRole(["owner", "admin", "moderator"]);
      if (error) return error;

      const usersCount = await env.db1
        .prepare("SELECT COUNT(*) AS c FROM users")
        .first();
      const personalCount = await env.db1
        .prepare("SELECT COUNT(*) AS c FROM posts_personal")
        .first();
      const merchantCount = await env.db1
        .prepare("SELECT COUNT(*) AS c FROM posts_product")
        .first();
      const pendingReports = await env.db1
        .prepare("SELECT COUNT(*) AS c FROM reports WHERE status = 'pending'")
        .first();

      return json({
        users: usersCount?.c || 0,
        personal_posts: personalCount?.c || 0,
        merchant_posts: merchantCount?.c || 0,
        pending_reports: pendingReports?.c || 0,
      });
    }

    /* ============================================
       BLOCK 16 — Fallback
    ============================================ */

    return notFound();
  },
};
