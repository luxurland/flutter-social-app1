import { json, error } from "../utils/response.js";
import { signJWT } from "../utils/jwt.js";

export async function login(request, env) {
  const { username, password } = await request.json();

  const user = await env.db1.prepare(
    "SELECT * FROM users WHERE username = ? AND password = ?"
  ).bind(username, password).first();

  if (!user) return error("Invalid credentials");

  const token = signJWT({ id: user.id, username }, env.JWT_SECRET);

  return json({ token });
}
