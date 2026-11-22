// Cloudflare Worker – GitHub Raw Proxy (No Token, No Expiry)
const REPO_OWNER = "riskibambela01-a11y";   // 🔁 Apna GitHub username daalo
const REPO_NAME = "online-server-2";            // 🔁 Apna repo name daalo
const BRANCH = "main";              // 🔁 Branch name (main or master)

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const method = request.method;

    // CORS preflight
    if (method === "OPTIONS") {
      return new Response(null, {
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type"
        }
      });
    }

    let filePath = "";
    if (method === "GET") {
      filePath = url.pathname.replace(/^\//, "");
    } else if (method === "POST") {
      const text = await request.text();
      const params = new URLSearchParams(text);
      filePath = params.get("key_path") || "";
    } else {
      return new Response("Method not allowed", { status: 405 });
    }

    // Only allow .lua files
    if (!filePath.endsWith(".lua") || filePath === "") {
      return new Response("Not found", { status: 404 });
    }

    // Direct GitHub raw URL – no token needed
    const rawUrl = `https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/${filePath}`;

    try {
      const resp = await fetch(rawUrl);
      if (!resp.ok) {
        return new Response("Not found", { status: 404 });
      }
      const body = await resp.text();
      return new Response(body, {
        headers: {
          "Content-Type": "text/plain; charset=utf-8",
          "Cache-Control": "no-store, max-age=0",
          "Access-Control-Allow-Origin": "*"
        }
      });
    } catch (err) {
      return new Response("Proxy error", { status: 502 });
    }
  }
};