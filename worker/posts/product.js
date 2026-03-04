import { json, error } from "../utils/response.js";

export async function createProductPost(request, env, user) {
  const { public_id, post_hex_id, product_id, cid, type } = await request.json();

  const product = await env.db1.prepare(
    "SELECT p.*, s.owner_id FROM products p JOIN stores s ON p.store_id = s.id WHERE p.id = ?"
  ).bind(product_id).first();

  if (!product) return error("Product not found");
  if (product.owner_id !== user.id) return error("Not allowed", 403);

  const result = await env.db1.prepare(
    "INSERT INTO posts_product (public_id, post_hex_id, owner_id, product_id, cid, type) VALUES (?, ?, ?, ?, ?, ?)"
  ).bind(public_id, post_hex_id, user.id, product_id, cid, type).run();

  return json({ post_id: result.lastInsertRowId });
}

export async function getProductFeed(request, env) {
  const rows = await env.db1.prepare(
    "SELECT * FROM posts_product WHERE hidden = 0 ORDER BY id DESC"
  ).all();

  return json(rows.results);
}

export async function hideProductPost(request, env, user) {
  const { post_id } = await request.json();

  const post = await env.db1.prepare(
    "SELECT * FROM posts_product WHERE id = ?"
  ).bind(post_id).first();

  if (!post) return error("Post not found");
  if (post.owner_id !== user.id) return error("Not allowed", 403);

  await env.db1.prepare(
    "UPDATE posts_product SET hidden = 1 WHERE id = ?"
  ).bind(post_id).run();

  return json({ hidden: true });
}
