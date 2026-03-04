import { json, error } from "../utils/response.js";
import { signJWT } from "../utils/jwt.js";

export async function register(request, env) {
  const { username, password } = await request.json();

  if (!username || !password) return error("Missing fields");

  const exists = await env.db1.prepare(
    "SELECT id FROM users WHERE username = ?"
  ).bind(username).first();

  if (exists) return error("User exists");

  const result = await env.db1.prepare(
    "INSERT INTO users (username, password) VALUES (?, ?)"
  ).bind(username, password).run();

  const token = signJWT({ id: result.lastInsertRowId, username }, env.JWT_SECRET);

  return json({ token });
}
