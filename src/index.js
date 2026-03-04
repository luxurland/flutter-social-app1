import { AES, enc } from "crypto-js";

function decryptAES128(encrypted) {
  const key = "MySecretKey12345";
  const bytes = AES.decrypt(encrypted, key);
  return bytes.toString(enc.Utf8);
}

async function getUserIdFromRequest(request) {
  const header = request.headers.get("x-user-id");
  if (!header) throw new Error("UNAUTHENTICATED");
  return header;
}

async function getFeaturePrice(env, featureKey) {
  const row = await env.db1
    .prepare("SELECT price FROM feature_prices WHERE feature_key = ?")
    .bind(featureKey)
    .first();
  if (!row) throw new Error(`Missing price for feature: ${featureKey}`);
  return row.price;
}

async function getUserBalance(env, userId) {
  const row = await env.db1
    .prepare("SELECT balance FROM wallets WHERE user_id = ?")
    .bind(userId)
    .first();
  return row ? row.balance : 0;
}

async function chargeUser(env, userId, amount, featureKey) {
  const balance = await getUserBalance(env, userId);
  if (balance < amount) throw new Error("INSUFFICIENT_BALANCE");

  const newBalance = balance - amount;

  await env.db1
    .prepare(
      `
      INSERT INTO wallets (user_id, balance)
      VALUES (?, ?)
      ON CONFLICT(user_id) DO UPDATE SET balance = excluded.balance, updated_at = CURRENT_TIMESTAMP
    `
    )
    .bind(userId, newBalance)
    .run();

  await env.db1
    .prepare(
      `
      INSERT INTO transactions (id, user_id, amount, type, feature_key)
      VALUES (?, ?, ?, 'spend', ?)
    `
    )
    .bind(crypto.randomUUID(), userId, amount, featureKey)
    .run();

  return newBalance;
}

async function addTempCallCharge(env, callId, userId, amount) {
  await env.db1
    .prepare(
      `
      INSERT INTO call_temp_wallet (id, call_id, user_id, amount)
      VALUES (?, ?, ?, ?)
    `
    )
    .bind(crypto.randomUUID(), callId, userId, amount)
    .run();
}

async function getCallGuestsCount(env, callId, creatorId) {
  const row = await env.db1
    .prepare(
      `
      SELECT COUNT(*) AS cnt
      FROM call_participants
      WHERE call_id = ?
    `
    )
    .bind(callId)
    .first();

  const total = row ? row.cnt : 0;
  return Math.max(total - 1, 0);
}

async function getCallTotalTempAmount(env, callId) {
  const row = await env.db1
    .prepare(
      `
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM call_temp_wallet
      WHERE call_id = ?
    `
    )
    .bind(callId)
    .first();
  return row ? row.total : 0;
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

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

    if (request.method === "POST" && url.pathname === "/calls/start") {
      try {
        const userId = await getUserIdFromRequest(request);
        const body = await request.json();
        const callType = body.call_type;

        if (callType !== "voice" && callType !== "video") {
          throw new Error("INVALID_CALL_TYPE");
        }

        const featureKey =
          callType === "voice" ? "call_voice_5min" : "call_video_5min";

        const pricePerGuest = await getFeaturePrice(env, featureKey);

        const guests = 1;
        const totalPrice = pricePerGuest * guests;

        await chargeUser(env, userId, totalPrice, featureKey);

        const callId = crypto.randomUUID();
        const now = new Date();
        const expires = new Date(now.getTime() + 5 * 60 * 1000);

        await env.db1
          .prepare(
            `
            INSERT INTO calls (id, creator_id, call_type, start_time, expires_at, total_price)
            VALUES (?, ?, ?, ?, ?, ?)
          `
          )
          .bind(
            callId,
            userId,
            callType,
            now.toISOString(),
            expires.toISOString(),
            totalPrice
          )
          .run();

        await env.db1
          .prepare(
            `
            INSERT INTO call_participants (id, call_id, user_id)
            VALUES (?, ?, ?)
          `
          )
          .bind(crypto.randomUUID(), callId, userId)
          .run();

        await addTempCallCharge(env, callId, userId, totalPrice);

        return new Response(
          JSON.stringify({
            success: true,
            call_id: callId,
            expires_at: expires.toISOString(),
            charged: totalPrice,
          }),
          { headers: { "Content-Type": "application/json" } }
        );
      } catch (e) {
        return new Response(
          JSON.stringify({ success: false, error: e.message }),
          { status: 400 }
        );
      }
    }

    if (request.method === "POST" && url.pathname === "/calls/add-participant") {
      try {
        const userId = await getUserIdFromRequest(request);
        const body = await request.json();
        const { call_id, new_user_id } = body;

        const call = await env.db1
          .prepare(
            `
            SELECT id, creator_id, call_type, expires_at, total_price
            FROM calls
            WHERE id = ?
          `
          )
          .bind(call_id)
          .first();

        if (!call) throw new Error("CALL_NOT_FOUND");
        if (call.creator_id !== userId) throw new Error("NOT_CALL_OWNER");

        const now = new Date();
        if (call.expires_at && new Date(call.expires_at) < now) {
          throw new Error("CALL_EXPIRED");
        }

        const featureKey =
          call.call_type === "voice"
            ? "call_voice_5min"
            : "call_video_5min";

        const pricePerGuest = await getFeaturePrice(env, featureKey);

        const extraPrice = pricePerGuest * 1;

        await chargeUser(env, userId, extraPrice, featureKey);

        await env.db1
          .prepare(
            `
            INSERT INTO call_participants (id, call_id, user_id)
            VALUES (?, ?, ?)
          `
          )
          .bind(crypto.randomUUID(), call_id, new_user_id)
          .run();

        const newTotal = (call.total_price || 0) + extraPrice;

        await env.db1
          .prepare(
            `
            UPDATE calls
            SET total_price = ?
            WHERE id = ?
          `
          )
          .bind(newTotal, call_id)
          .run();

        await addTempCallCharge(env, call_id, userId, extraPrice);

        return new Response(
          JSON.stringify({
            success: true,
            call_id,
            extra_charged: extraPrice,
            total_price: newTotal,
          }),
          { headers: { "Content-Type": "application/json" } }
        );
      } catch (e) {
        return new Response(
          JSON.stringify({ success: false, error: e.message }),
          { status: 400 }
        );
      }
    }

    if (request.method === "POST" && url.pathname === "/calls/extend") {
      try {
        const userId = await getUserIdFromRequest(request);
        const body = await request.json();
        const { call_id, duration } = body;

        const call = await env.db1
          .prepare(
            `
            SELECT id, creator_id, call_type, expires_at, total_price
            FROM calls
            WHERE id = ?
          `
          )
          .bind(call_id)
          .first();

        if (!call) throw new Error("CALL_NOT_FOUND");
        if (call.creator_id !== userId) throw new Error("NOT_CALL_OWNER");

        if (!["15", "30", "60"].includes(String(duration))) {
          throw new Error("INVALID_DURATION");
        }

        const featureKey =
          call.call_type === "voice"
            ? `call_voice_${duration}min`
            : `call_video_${duration}min`;

        const pricePerGuest = await getFeaturePrice(env, featureKey);

        const guests = await getCallGuestsCount(env, call_id, call.creator_id);

        const totalPrice = pricePerGuest * guests;

        await chargeUser(env, userId, totalPrice, featureKey);

        const currentExpires = call.expires_at
          ? new Date(call.expires_at)
          : new Date();
        const extraMs = parseInt(duration, 10) * 60 * 1000;
        const newExpires = new Date(currentExpires.getTime() + extraMs);

        const newTotal = (call.total_price || 0) + totalPrice;

        await env.db1
          .prepare(
            `
            UPDATE calls
            SET expires_at = ?, total_price = ?
            WHERE id = ?
          `
          )
          .bind(newExpires.toISOString(), newTotal, call_id)
          .run();

        await addTempCallCharge(env, call_id, userId, totalPrice);

        return new Response(
          JSON.stringify({
            success: true,
            call_id,
            added_duration: duration,
            extra_charged: totalPrice,
            total_price: newTotal,
            expires_at: newExpires.toISOString(),
          }),
          { headers: { "Content-Type": "application/json" } }
        );
      } catch (e) {
        return new Response(
          JSON.stringify({ success: false, error: e.message }),
          { status: 400 }
        );
      }
    }

    if (request.method === "POST" && url.pathname === "/calls/end") {
      try {
        const userId = await getUserIdFromRequest(request);
        const body = await request.json();
        const { call_id } = body;

        const call = await env.db1
          .prepare(
            `
            SELECT id, creator_id
            FROM calls
            WHERE id = ?
          `
          )
          .bind(call_id)
          .first();

        if (!call) throw new Error("CALL_NOT_FOUND");
        if (call.creator_id !== userId) throw new Error("NOT_CALL_OWNER");

        const now = new Date();

        await env.db1
          .prepare(
            `
            UPDATE calls
            SET end_time = ?
            WHERE id = ?
          `
          )
          .bind(now.toISOString(), call_id)
          .run();

        const totalTemp = await getCallTotalTempAmount(env, call_id);

        const ownerId = "OWNER_ACCOUNT_ID";

        const ownerBalance = await getUserBalance(env, ownerId);
        const newOwnerBalance = ownerBalance + totalTemp;

        await env.db1
          .prepare(
            `
            INSERT INTO wallets (user_id, balance)
            VALUES (?, ?)
            ON CONFLICT(user_id) DO UPDATE SET balance = excluded.balance, updated_at = CURRENT_TIMESTAMP
          `
          )
          .bind(ownerId, newOwnerBalance)
          .run();

        await env.db1
          .prepare(
            `
            INSERT INTO transactions (id, user_id, amount, type, feature_key)
            VALUES (?, ?, ?, 'payout', 'call_payout')
          `
          )
          .bind(crypto.randomUUID(), ownerId, totalTemp)
          .run();

        return new Response(
          JSON.stringify({
            success: true,
            call_id,
            total_collected: totalTemp,
          }),
          { headers: { "Content-Type": "application/json" } }
        );
      } catch (e) {
        return new Response(
          JSON.stringify({ success: false, error: e.message }),
          { status: 400 }
        );
      }
    }

    return new Response("Not found", { status: 404 });
  },
};
