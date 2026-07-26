const toCamelCase = (key) => key.replace(/_([a-z0-9])/g, (_, char) => char.toUpperCase());

/**
 * The mobile client posts snake_case keys that mirror the database columns,
 * while the controllers read camelCase. Add camelCase aliases so both shapes
 * are accepted without duplicating the destructuring in every controller.
 */
const normalizeBodyMiddleware = (req, res, next) => {
  const body = req.body;

  if (body && typeof body === 'object' && !Array.isArray(body)) {
    for (const [key, value] of Object.entries(body)) {
      const camelKey = toCamelCase(key);
      if (camelKey !== key && body[camelKey] === undefined) {
        body[camelKey] = value;
      }
    }
  }

  next();
};

module.exports = normalizeBodyMiddleware;
