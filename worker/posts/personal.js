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

export async function createPersonalPost(request, env, user) {
  const { content } = await request.json();
  if (!content) {
    return new Response(JSON.stringify({ error: "Missing content" }), {
      status: 400,
      headers: { "Content-Type": "application/json" }
    });
  }

  const result = await env.DB.prepare(
    "INSERT INTO personal_posts (user_id, content, created_at) VALUES (?, ?, ?)"
  )
    .bind(user.id, content, new Date().toISOString())
    .run();

  return new Response(JSON.stringify({ id: result.lastInsertRowId }), {
    status: 200,
    headers: { "Content-Type": "application/json" }
  });
}
