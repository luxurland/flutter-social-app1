import { error } from "./response.js";

export function signJWT(payload, secret) {
  const header = btoa(JSON.stringify({ alg: "HS256", typ: "JWT" }));
  const body = btoa(JSON.stringify(payload));
  const signature = btoa(
    crypto.subtle.digestSync("SHA-256", new TextEncoder().encode(header + body + secret))
  );
  return `${header}.${body}.${signature}`;
}

export function verifyJWT(token, secret) {
  try {
    const [header, body, signature] = token.split(".");
    const check = btoa(
      crypto.subtle.digestSync("SHA-256", new TextEncoder().encode(header + body + secret))
    );
    if (check !== signature) return null;
    return JSON.parse(atob(body));
  } catch {
    return null;
  }
}
