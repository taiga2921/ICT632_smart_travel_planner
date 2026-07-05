const validateRequired = (fields) => (req, res, next) => {
  const errors = {};

  for (const field of fields) {
    const value = req.body[field];
    if (value === undefined || value === null || value === '') {
      errors[field] = `${field} is required`;
    }
  }

  if (Object.keys(errors).length > 0) {
    return res.status(422).json({
      success: false,
      message: 'Validation failed',
      errors,
    });
  }

  next();
};

const validateQueryRequired = (fields) => (req, res, next) => {
  const errors = {};

  for (const field of fields) {
    const value = req.query[field];
    if (value === undefined || value === null || value === '') {
      errors[field] = `${field} is required`;
    }
  }

  if (Object.keys(errors).length > 0) {
    return res.status(422).json({
      success: false,
      message: 'Validation failed',
      errors,
    });
  }

  next();
};

module.exports = { validateRequired, validateQueryRequired };
