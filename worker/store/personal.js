import { json, error } from "../utils/response.js";

export async function createPersonalPost(request, env, user) {
  const { public_id, post_hex_id, cid, type } = await request.json();

  const result = await env.db1.prepare(
    "INSERT INTO posts_personal (public_id, post_hex_id, owner_id, cid, type) VALUES (?, ?, ?, ?, ?)"
  ).bind(public_id, post_hex_id, user.id, cid, type).run();

  return json({ post_id: result.lastInsertRowId });
}

export async function getPersonalFeed(request, env) {
  const rows = await env.db1.prepare(
    "SELECT * FROM posts_personal WHERE hidden = 0 ORDER BY id DESC"
  ).all();

  return json(rows.results);
}

export async function hidePersonalPost(request, env, user) {
  const { post_id } = await request.json();

  const post = await env.db1.prepare(
    "SELECT * FROM posts_personal WHERE id = ?"
  ).bind(post_id).first();

  if (!post) return error("Post not found");
  if (post.owner_id !== user.id) return error("Not allowed", 403);

  await env.db1.prepare(
    "UPDATE posts_personal SET hidden = 1 WHERE id = ?"
  ).bind(post_id).run();

  return json({ hidden: true });
}
