import { register } from "./auth/register.js";
import { login } from "./auth/login.js";
import { requireAuth } from "./auth/middleware.js";

import { startCall } from "./calls/startCall.js";
import { addParticipant } from "./calls/addParticipant.js";
import { extendCall } from "./calls/extendCall.js";
import { endCall } from "./calls/endCall.js";
import { callHistory } from "./calls/history.js";

import { createStore, getMyStore, getStoreById } from "./store/store.js";
import { createProduct, getProductsByStore, hideProduct } from "./store/products.js";

import { createPersonalPost, getPersonalFeed, hidePersonalPost } from "./posts/personal.js";
import { createProductPost, getProductFeed, hideProductPost } from "./posts/product.js";

import { reportPost, getReports, resolveReport } from "./posts/reports.js";

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const path = url.pathname;
    const method = request.method;

    // Public
    if (path === "/register" && method === "POST") return register(request, env);
    if (path === "/login" && method === "POST") return login(request, env);

    // Auth
    const user = await requireAuth(request, env);
    if (user instanceof Response) return user;

    // Calls
    if (path === "/call/start" && method === "POST") return startCall(request, env, user);
    if (path === "/call/add" && method === "POST") return addParticipant(request, env, user);
    if (path === "/call/extend" && method === "POST") return extendCall(request, env);
    if (path === "/call/end" && method === "POST") return endCall(request, env);
    if (path === "/call/history" && method === "GET") return callHistory(request, env, user);

    // Store
    if (path === "/store/create" && method === "POST") return createStore(request, env, user);
    if (path === "/store/me" && method === "GET") return getMyStore(request, env, user);
    if (path === "/store/get" && method === "GET") return getStoreById(request, env);

    // Products
    if (path === "/product/create" && method === "POST") return createProduct(request, env, user);
    if (path === "/product/by-store" && method === "GET") return getProductsByStore(request, env);
    if (path === "/product/hide" && method === "POST") return hideProduct(request, env, user);

    // Personal posts
    if (path === "/posts/personal/create" && method === "POST") return createPersonalPost(request, env, user);
    if (path === "/posts/personal/feed" && method === "GET") return getPersonalFeed(request, env);
    if (path === "/posts/personal/hide" && method === "POST") return hidePersonalPost(request, env, user);

    // Product posts
    if (path === "/posts/product/create" && method === "POST") return createProductPost(request, env, user);
    if (path === "/posts/product/feed" && method === "GET") return getProductFeed(request, env);
    if (path === "/posts/product/hide" && method === "POST") return hideProductPost(request, env, user);

    // Reports
    if (path === "/reports/create" && method === "POST") return reportPost(request, env, user);
    if (path === "/reports/all" && method === "GET") return getReports(request, env);
    if (path === "/reports/resolve" && method === "POST") return resolveReport(request, env);

    return new Response("Not found", { status: 404 });
  }
};
