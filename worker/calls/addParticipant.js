import { json } from "../utils/response.js";

export async function addParticipant(request, env, user) {
  const { call_id } = await request.json();

  await env.db1.prepare(
    "INSERT INTO call_participants (call_id, user_id) VALUES (?, ?)"
  ).bind(call_id, user.id).run();

  return json({ joined: true });
}
