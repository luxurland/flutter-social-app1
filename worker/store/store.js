import { json, error } from "../utils/response.js";

export async function createStore(request, env, user) {
  try {
    const { name, description } = await request.json();

    if (!name) {
      return error("Store name is required", 400);
    }

    const existing = await env.DB.prepare(
      "SELECT id FROM stores WHERE owner_id = ?"
    ).bind(user.id).first();

    if (existing) {
      return error("User already has a store", 409);
    }

    const result = await env.DB.prepare(
      "INSERT INTO stores (owner_id, name, description) VALUES (?, ?, ?)"
    ).bind(user.id, name, description || null).run();

    return json({ 
      success: true,
      store_id: result.meta.last_row_id 
    }, 201);

  } catch (err) {
    console.error("Error creating store:", err);
    return error("Failed to create store", 500);
  }
}

export async function getMyStore(request, env, user) {
  try {
    const store = await env.DB.prepare(
      "SELECT * FROM stores WHERE owner_id = ?"
    ).bind(user.id).first();

    if (!store) {
      return json({ store: null, message: "No store found" });
    }

    return json({ store });

  } catch (err) {
    console.error("Error getting store:", err);
    return error("Failed to get store", 500);
  }
}

export async function getStoreById(request, env) {
  try {
    const url = new URL(request.url);
    const id = url.searchParams.get("id");

    if (!id) {
      return error("Store ID is required", 400);
    }

    const store = await env.DB.prepare(
      "SELECT * FROM stores WHERE id = ?"
    ).bind(Number(id)).first();

    if (!store) {
      return error("Store not found", 404);
    }

    return json({ store });

  } catch (err) {
    console.error("Error getting store by ID:", err);
    return error("Failed to get store", 500);
  }
}
