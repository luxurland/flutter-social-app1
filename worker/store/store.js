// TEMPORARY DEBUGGING FOR STORE
console.log('✅ Store module loaded');
console.log('✅ Store functions:', {
  createStore: typeof createStore,
  getMyStore: typeof getMyStore,
  getStoreById: typeof getStoreById
});


import { json, error } from "../utils/response.js";

export async function createStore(request, env, user) {
  const { name, description } = await request.json();

  const result = await env.db1.prepare(
    "INSERT INTO stores (owner_id, name, description) VALUES (?, ?, ?)"
  ).bind(user.id, name, description).run();

  return json({ store_id: result.lastInsertRowId });
}

export async function getMyStore(request, env, user) {
  const store = await env.db1.prepare(
    "SELECT * FROM stores WHERE owner_id = ?"
  ).bind(user.id).first();

  return json(store || {});
}

export async function getStoreById(request, env) {
  const id = Number(new URL(request.url).searchParams.get("id"));

  const store = await env.db1.prepare(
    "SELECT * FROM stores WHERE id = ?"
  ).bind(id).first();

  if (!store) return error("Store not found", 404);

  return json(store);
}
