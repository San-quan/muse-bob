import { fetchWithTimeout } from "../src/lib/fetch-with-timeout.js";

describe("fetchWithTimeout", () => {
  const originalFetch = global.fetch;

  afterEach(() => {
    global.fetch = originalFetch;
    jest.resetAllMocks();
  });

  test("times out and throws AbortError", async () => {
    global.fetch = jest.fn(() => new Promise(() => {}));
    const p = fetchWithTimeout("https://example.com/slow", {}, 50, { retries: 0 });
    await expect(p).rejects.toThrow();
  });

  test("retries on transient AbortError for GET", async () => {
    let called = 0;
    global.fetch = jest.fn(() => {
      called++;
      if (called < 2) {
        const e = new Error("Aborted");
        e.name = "AbortError";
        return Promise.reject(e);
      }
      return Promise.resolve({
        ok: true,
        status: 200,
        text: async () => "ok"
      });
    });

    const res = await fetchWithTimeout("https://example.com/retry", { method: "GET" }, 50, { retries: 2, retryDelay: 1 });
    const txt = await res.text();
    expect(txt).toBe("ok");
    expect(called).toBeGreaterThanOrEqual(2);
  });
});
