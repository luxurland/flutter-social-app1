import { json } from "../utils/response.js";

export async function callHistory(request, env, user) {
  const rows = await env.db1.prepare(
    "SELECT * FROM calls WHERE creator_id = ? ORDER BY id DESC"
  ).bind(user.id).all();

  return json(rows.results);
}
