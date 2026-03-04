import { json, error } from "../utils/response.js";

export async function createProduct(request, env, user) {
  const { store_id, name, description, price, stock } = await request.json();

  const store = await env.db1.prepare(
    "SELECT * FROM stores WHERE id = ? AND owner_id = ?"
  ).bind(store_id, user.id).first();

  if (!store) return error("You do not own this store", 403);

  const result = await env.db1.prepare(
    "INSERT INTO products (store_id, name, description, price, stock) VALUES (?, ?, ?, ?, ?)"
  ).bind(store_id, name, description, price, stock).run();

  return json({ product_id: result.lastInsertRowId });
}

export async function getProductsByStore(request, env) {
  const storeId = Number(new URL(request.url).searchParams.get("store_id"));

  const rows = await env.db1.prepare(
    "SELECT * FROM products WHERE store_id = ? AND hidden = 0"
  ).bind(storeId).all();

  return json(rows.results);
}

export async function hideProduct(request, env, user) {
  const { product_id } = await request.json();

  const product = await env.db1.prepare(
    "SELECT p.*, s.owner_id FROM products p JOIN stores s ON p.store_id = s.id WHERE p.id = ?"
  ).bind(product_id).first();

  if (!product) return error("Product not found");
  if (product.owner_id !== user.id) return error("Not allowed", 403);

  await env.db1.prepare(
    "UPDATE products SET hidden = 1 WHERE id = ?"
  ).bind(product_id).run();

  return json({ hidden: true });
}
