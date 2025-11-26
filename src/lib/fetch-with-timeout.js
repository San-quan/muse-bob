// Lightweight fetch wrapper with timeout and optional retries.
// Usage:
//   import { fetchWithTimeout } from './lib/fetch-with-timeout.js'
//   const res = await fetchWithTimeout(url, { method: 'GET' }, 30000, { retries: 2 })

export async function fetchWithTimeout(resource, options = {}, timeout = 30000, opts = {}) {
  const { retries = 0, retryDelay = 500 } = opts;
  const attempt = async (n, delay) => {
    const controller = new AbortController();
    const id = setTimeout(() => controller.abort(), timeout);
    try {
      // Node 18+ has global fetch. If running in older node, ensure global fetch polyfill.
      const res = await fetch(resource, { ...options, signal: controller.signal });
      clearTimeout(id);
      if (!res.ok && n < retries) {
        // for non-2xx responses, optionally retry for idempotent GETs
        if ((options.method || 'GET').toUpperCase() === 'GET') {
          await new Promise((r) => setTimeout(r, delay));
          return attempt(n + 1, Math.min(delay * 2, 5000));
        }
      }
      return res;
    } catch (err) {
      clearTimeout(id);
      // AbortError or network errors
      if (n < retries && (err.name === 'AbortError' || err.code === 'ECONNRESET' || err.code === 'ETIMEDOUT')) {
        await new Promise((r) => setTimeout(r, delay));
        return attempt(n + 1, Math.min(delay * 2, 5000));
      }
      throw err;
    }
  };

  return attempt(0, retryDelay);
}
