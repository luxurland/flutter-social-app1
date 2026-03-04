import { json } from "../utils/response.js";

export async function endCall(request, env) {
  const { call_id } = await request.json();

  await env.db1.prepare(
    "UPDATE calls SET end_time = ? WHERE id = ?"
  ).bind(new Date().toISOString(), call_id).run();

  return json({ ended: true });
}
