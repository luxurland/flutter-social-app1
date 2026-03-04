import { json, error } from "../utils/response.js";

export async function reportPost(request, env, user) {
  const { post_type, post_public_id, reason } = await request.json();

  await env.db1.prepare(
    "INSERT INTO reports (post_type, post_public_id, reporter_id, reason) VALUES (?, ?, ?, ?)"
  ).bind(post_type, post_public_id, user.id, reason).run();

  return json({ reported: true });
}

export async function getReports(request, env) {
  const rows = await env.db1.prepare(
    "SELECT * FROM reports ORDER BY id DESC"
  ).all();

  return json(rows.results);
}

export async function resolveReport(request, env) {
  const { report_id } = await request.json();

  await env.db1.prepare(
    "UPDATE reports SET status = 'resolved' WHERE id = ?"
  ).bind(report_id).run();

  return json({ resolved: true });
}
