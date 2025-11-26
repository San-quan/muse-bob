import { fetchWithTimeout } from '../src/lib/fetch-with-timeout.js';

// Simple unit tests mocking global.fetch
describe('fetchWithTimeout', () => {
  const originalFetch = global.fetch;

  afterEach(() => {
    global.fetch = originalFetch;
  });

  test('times out and throws AbortError', async () => {
    // simulate a fetch that respects abort signal
    global.fetch = (url, options) => {
      return new Promise((resolve, reject) => {
        // Listen for abort signal
        if (options?.signal) {
          options.signal.addEventListener('abort', () => {
            const err = new Error('The operation was aborted');
            err.name = 'AbortError';
            reject(err);
          });
        }
        // Never resolve normally
      });
    };
    const p = fetchWithTimeout('https://example.com/slow', {}, 50, { retries: 0 });
    await expect(p).rejects.toThrow();
  }, 1000); // 1 second timeout for the test itself

  test('retries on transient AbortError for GET', async () => {
    let called = 0;
    global.fetch = () => {
      called++;
      if (called < 2) {
        const e = new Error('Aborted');
        e.name = 'AbortError';
        return Promise.reject(e);
      }
      return Promise.resolve({
        ok: true,
        status: 200,
        text: async () => 'ok'
      });
    };

    const res = await fetchWithTimeout('https://example.com/retry', { method: 'GET' }, 50, { retries: 2, retryDelay: 1 });
    const txt = await res.text();
    expect(txt).toBe('ok');
    expect(called).toBeGreaterThanOrEqual(2);
  });
});
