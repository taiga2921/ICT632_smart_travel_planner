/**
 * Reads an optional field from a request body.
 *
 * Using `body[key] ?? fallback` would make it impossible to clear a nullable
 * column, because an explicit `null` from the client falls back to the stored
 * value. Only fall back when the key is absent from the payload.
 */
const pick = (body, key, fallback) =>
  Object.prototype.hasOwnProperty.call(body, key) ? body[key] : fallback;

module.exports = { pick };
