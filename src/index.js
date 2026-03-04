import { AES, enc } from "crypto-js";

function decryptAES128(encrypted) {
  const key = "MySecretKey12345"; // same key as Flutter
  const bytes = AES.decrypt(encrypted, key);
  return bytes.toString(enc.Utf8);
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    // REGISTER
    if (request.method === "POST" && url.pathname === "/auth/register") {
      const body = await request.json();

      const email = decryptAES128(body.email);
      const password = decryptAES128(body.password);

      const id = crypto.randomUUID();

      await env.db1
        .prepare(
          `INSERT INTO users (id, email, password_hash) VALUES (?, ?, ?)`
        )
        .bind(id, email, password)
        .run();

      return new Response(JSON.stringify({ success: true }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    // LOGIN
    if (request.method === "POST" && url.pathname === "/auth/login") {
      const body = await request.json();

      const email = decryptAES128(body.email);
      const password = decryptAES128(body.password);

      const row = await env.db1
        .prepare(
          `SELECT id, email, password_hash, email_verified, role FROM users WHERE email = ?`
        )
        .bind(email)
        .first();

      if (!row || row.password_hash !== password) {
        return new Response(
          JSON.stringify({ success: false, error: "Invalid credentials" }),
          { headers: { "Content-Type": "application/json" } }
        );
      }

      if (!row.email_verified) {
        return new Response(
          JSON.stringify({ success: false, error: "Email not verified" }),
          { headers: { "Content-Type": "application/json" } }
        );
      }

      return new Response(JSON.stringify({ success: true, user: row }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    return new Response("Not found", { status: 404 });
  },
};
