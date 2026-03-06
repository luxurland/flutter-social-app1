import { json, error } from "../utils/response.js";
import { signJWT } from "../utils/jwt.js";
import bcrypt from 'bcryptjs';

export async function register(request, env) {
  if (request.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
        "Access-Control-Max-Age": "86400"
      }
    });
  }

  try {
    const { username, password } = await request.json();

    if (!username || !password) {
      return error("Missing fields", 400);
    }

    const exists = await env.DB.prepare(
      "SELECT id FROM users WHERE username = ?"
    ).bind(username).first();

    if (exists) {
      return error("User already exists", 409);
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const user_hex_id = [...Array(16)].map(() => Math.floor(Math.random() * 16).toString(16)).join('');

    const result = await env.DB.prepare(
      "INSERT INTO users (username, password, user_hex_id) VALUES (?, ?, ?)"
    ).bind(username, hashedPassword, user_hex_id).run();

    await env.DB.prepare(
      "INSERT INTO wallets (user_id, balance) VALUES (?, 0)"
    ).bind(result.meta.last_row_id).run();

    const token = signJWT(
      { 
        id: result.meta.last_row_id, 
        username, 
        user_hex_id 
      }, 
      env.JWT_SECRET
    );

    return json({ 
      token,
      user: {
        id: result.meta.last_row_id,
        username,
        user_hex_id
      }
    }, 201);

  } catch (err) {
    console.error('Registration error:', err);
    return error("Internal server error", 500);
  }
}
