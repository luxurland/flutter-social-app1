import { json, error } from "../utils/response.js";
import { signJWT } from "../utils/jwt.js";
import bcrypt from 'bcryptjs';

export async function login(request, env) {
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

    const user = await env.DB.prepare(
      "SELECT id, username, password, user_hex_id, banned FROM users WHERE username = ?"
    ).bind(username).first();

    if (!user) {
      return error("Invalid credentials", 401);
    }

    if (user.banned === 1) {
      return error("Account is banned", 403);
    }

    const validPassword = await bcrypt.compare(password, user.password);
    
    if (!validPassword) {
      return error("Invalid credentials", 401);
    }

    const token = signJWT(
      { 
        id: user.id, 
        username: user.username,
        user_hex_id: user.user_hex_id
      }, 
      env.JWT_SECRET
    );

    return json({ 
      token,
      user: {
        id: user.id,
        username: user.username,
        user_hex_id: user.user_hex_id
      }
    });

  } catch (err) {
    console.error('Login error:', err);
    return error("Internal server error", 500);
  }
}
