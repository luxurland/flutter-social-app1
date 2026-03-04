import { json, error } from "../utils/response.js";

export async function extendCall(request, env) {
  const { call_id, minutes } = await request.json();

  const call = await env.db1.prepare(
    "SELECT expires_at FROM calls WHERE id = ?"
  ).bind(call_id).first();

  if (!call) return error("Call not found");

  const new_expiry = new Date(call.expires_at);
  new_expiry.setMinutes(new_expiry.getMinutes() + minutes);

  await env.db1.prepare(
    "UPDATE calls SET expires_at = ? WHERE id = ?"
  ).bind(new_expiry.toISOString(), call_id).run();

  return json({ expires_at: new_expiry });
}
