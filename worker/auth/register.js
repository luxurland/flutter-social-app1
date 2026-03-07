import { json, error } from "../utils/response.js";
import { signJWT } from "../utils/jwt.js";
import bcrypt from 'bcryptjs';

function validateCredentials(username, password) {
  const errors = [];
  
  if (!username || username.length < 3) {
    errors.push("Username must be at least 3 characters long");
  }
  if (!username || username.length > 30) {
    errors.push("Username must be less than 30 characters");
  }
  if (!username || !/^[a-zA-Z0-9_]+$/.test(username)) {
    errors.push("Username can only contain letters, numbers, and underscores");
  }
  
  if (!password || password.length < 6) {
    errors.push("Password must be at least 6 characters long");
  }
  if (!password || password.length > 100) {
    errors.push("Password must be less than 100 characters");
  }
  
  return errors;
}

function generateUserHexId() {
  return [...Array(16)]
    .map(() => Math.floor(Math.random() * 16).toString(16))
    .join('');
}

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

  if (request.method !== "POST") {
    return error("Method not allowed", 405);
  }

  try {
    let body;
    try {
      body = await request.json();
    } catch (e) {
      return error("Invalid JSON payload", 400);
    }

    const { username, password } = body;

    const validationErrors = validateCredentials(username, password);
    if (validationErrors.length > 0) {
      return error(validationErrors.join(", "), 400);
    }

    if (!env.JWT_SECRET) {
      console.error("JWT_SECRET is not configured in environment variables");
      return error("Server configuration error", 500);
    }

    if (!env.DB) {
      console.error("Database binding 'DB' is not configured");
      return error("Server configuration error", 500);
    }

    let exists;
    try {
      exists = await env.DB.prepare(
        "SELECT id FROM users WHERE username = ?"
      ).bind(username).first();
    } catch (dbError) {
      console.error("Database error checking existing user:", dbError);
      return error("Database error", 500);
    }

    if (exists) {
      return error("User already exists", 409);
    }

    let hashedPassword;
    try {
      hashedPassword = await bcrypt.hash(password, 10);
    } catch (hashError) {
      console.error("Error hashing password:", hashError);
      return error("Error processing password", 500);
    }

    const user_hex_id = generateUserHexId();

    let result;
    try {
      result = await env.DB.prepare(
        "INSERT INTO users (username, password, user_hex_id) VALUES (?, ?, ?)"
      ).bind(username, hashedPassword, user_hex_id).run();
    } catch (dbError) {
      console.error("Error inserting user:", dbError);
      return error("Error creating user", 500);
    }

    const userId = result.meta.last_row_id;

    try {
      await env.DB.prepare(
        "INSERT INTO wallets (user_id, balance) VALUES (?, 0)"
      ).bind(userId).run();
    } catch (dbError) {
      console.error("Error creating wallet for user:", dbError);
    }

    let token;
    try {
      token = signJWT(
        { 
          id: userId, 
          username, 
          user_hex_id 
        }, 
        env.JWT_SECRET
      );
    } catch (tokenError) {
      console.error("Error generating JWT:", tokenError);
      return error("Error creating authentication token", 500);
    }

    return json({ 
      success: true,
      token,
      user: {
        id: userId,
        username,
        user_hex_id
      }
    }, 201);

  } catch (err) {
    console.error('Unexpected registration error:', {
      message: err.message,
      stack: err.stack,
      name: err.name
    });
    
    return error("An unexpected error occurred", 500);
  }
}
