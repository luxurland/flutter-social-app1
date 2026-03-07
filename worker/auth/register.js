// /worker/auth/register.js
import { json, error } from "../utils/response.js";
import { signJWT } from "../utils/jwt.js";
import bcrypt from 'bcryptjs';

/**
 * Validate username and password format
 */
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

/**
 * Generate a random hex ID for user
 */
function generateUserHexId() {
  return [...Array(16)]
    .map(() => Math.floor(Math.random() * 16).toString(16))
    .join('');
}

export async function register(request, env) {
  // Handle CORS preflight
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

  // Only accept POST requests
  if (request.method !== "POST") {
    return error("Method not allowed", 405);
  }

  try {
    // ===== DEBUGGING LOGS - START =====
    // TODO: Remove these logs after confirming JWT_SECRET and DB are working
    console.log('================ DEBUG INFO ================');
    console.log('JWT_SECRET exists:', !!env.JWT_SECRET);
    console.log('JWT_SECRET type:', typeof env.JWT_SECRET);
    console.log('JWT_SECRET length:', env.JWT_SECRET ? env.JWT_SECRET.length : 0);
    
    console.log('DB binding exists:', !!env.DB);
    console.log('DB type:', typeof env.DB);
    console.log('All env keys:', Object.keys(env).join(', '));
    console.log('============================================');
    // ===== DEBUGGING LOGS - END =====

    // Parse request body
    let body;
    try {
      body = await request.json();
    } catch (e) {
      return error("Invalid JSON payload", 400);
    }

    const { username, password } = body;

    // Validate input
    const validationErrors = validateCredentials(username, password);
    if (validationErrors.length > 0) {
      return error(validationErrors.join(", "), 400);
    }

    // Check if JWT_SECRET is configured
    if (!env.JWT_SECRET) {
      console.error("JWT_SECRET is not configured in environment variables");
      return error("Server configuration error", 500);
    }

    // Check if database binding exists
    if (!env.DB) {
      console.error("Database binding 'DB' is not configured");
      return error("Server configuration error", 500);
    }

    // Check if user exists
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

    // Hash password
    let hashedPassword;
    try {
      hashedPassword = await bcrypt.hash(password, 10);
    } catch (hashError) {
      console.error("Error hashing password:", hashError);
      return error("Error processing password", 500);
    }

    // Generate unique hex ID
    const user_hex_id = generateUserHexId();

    // Insert user
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

    // Create wallet for user
    try {
      await env.DB.prepare(
        "INSERT INTO wallets (user_id, balance) VALUES (?, 0)"
      ).bind(userId).run();
    } catch (dbError) {
      console.error("Error creating wallet for user:", dbError);
      // Log error but don't fail registration - wallet can be created later
    }

    // Generate JWT token
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

    // Return success response
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
    // Catch any unexpected errors
    console.error('Unexpected registration error:', {
      message: err.message,
      stack: err.stack,
      name: err.name
    });
    
    return error("An unexpected error occurred", 500);
  }
}
