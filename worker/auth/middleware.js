import { verifyJWT } from "../utils/jwt.js";
import { error } from "../utils/response.js";

export async function requireAuth(request, env) {
  const token = request.headers.get("Authorization");
  if (!token) return error("Missing token", 401);

  const user = verifyJWT(token.replace("Bearer ", ""), env.JWT_SECRET);
  if (!user) return error("Invalid token", 401);

  return user;
}
