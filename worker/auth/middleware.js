// import { verifyJWT } from "../utils/jwt.js";
// import { error } from "../utils/response.js";

// export async function requireAuth(request, env) {
//   const token = request.headers.get("Authorization");
//   if (!token) return error("Missing token", 401);

//   const user = verifyJWT(token.replace("Bearer ", ""), env.JWT_SECRET);
//   if (!user) return error("Invalid token", 401);

//   return user;
// }


// /flutter-social-app1/worker/auth/middleware.js
import { verifyJWT } from "../utils/jwt.js";
import { error } from "../utils/response.js";

export async function requireAuth(request, env) {
  if (request.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
        "Access-Control-Max-Age": "86400"
      }
    });
  }

  const authHeader = request.headers.get("Authorization");
  
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return error("Missing or invalid authorization token", 401);
  }

  const token = authHeader.substring(7);
  const user = verifyJWT(token, env.JWT_SECRET);

  if (!user) {
    return error("Invalid or expired token", 401);
  }

  const dbUser = await env.DB.prepare(
    "SELECT id, banned FROM users WHERE id = ?"
  ).bind(user.id).first();

  if (!dbUser) {
    return error("User not found", 401);
  }

  if (dbUser.banned === 1) {
    return error("Account is banned", 403);
  }

  return user;
}
