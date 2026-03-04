import { register } from "./auth/register.js";
import { login } from "./auth/login.js";
import { requireAuth } from "./auth/middleware.js";

import { startCall } from "./calls/startCall.js";
import { addParticipant } from "./calls/addParticipant.js";
import { extendCall } from "./calls/extendCall.js";
import { endCall } from "./calls/endCall.js";
import { callHistory } from "./calls/history.js";

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    // AUTH
    if (url.pathname === "/register") return register(request, env);
    if (url.pathname === "/login") return login(request, env);

    // Protected routes
    const user = await requireAuth(request, env);
    if (user.error) return user;

    if (url.pathname === "/call/start") return startCall(request, env, user);
    if (url.pathname === "/call/add") return addParticipant(request, env, user);
    if (url.pathname === "/call/extend") return extendCall(request, env);
    if (url.pathname === "/call/end") return endCall(request, env);
    if (url.pathname === "/call/history") return callHistory(request, env, user);

    return new Response("Not found", { status: 404 });
  }
};
