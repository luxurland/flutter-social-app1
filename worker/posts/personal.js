export async function getPersonalFeed(env, userId) {
  const result = await env.DB.prepare(
    "SELECT * FROM posts WHERE user_id = ? ORDER BY created_at DESC"
  ).bind(userId).all();

  return result.results;
}

export async function hidePersonalPost(env, postId) {
  await env.DB.prepare(
    "UPDATE posts SET hidden = 1 WHERE id = ?"
  ).bind(postId).run();

  return { success: true };
}
