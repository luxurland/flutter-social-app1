import { json, error } from "../utils/response.js";

export async function startCall(request, env, user) {
  const { call_type, duration } = await request.json();

  const expires_at = new Date(Date.now() + duration * 60000).toISOString();

  const result = await env.db1.prepare(
    "INSERT INTO calls (creator_id, call_type, start_time, expires_at) VALUES (?, ?, ?, ?)"
  ).bind(user.id, call_type, new Date().toISOString(), expires_at).run();

  return json({ call_id: result.lastInsertRowId, expires_at });
}
