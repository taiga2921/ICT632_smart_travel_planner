const axios = require('axios');

const search = async (name) => {
  const response = await axios.get(
    'https://geocoding-api.open-meteo.com/v1/search',
    {
      params: {
        name,
        count: 1,
        language: 'en',
        format: 'json',
      },
    }
  );

  const results = response.data.results;
  return results && results.length > 0 ? results[0] : null;
};

/**
 * Converts a location name to latitude and longitude using the Open-Meteo
 * geocoding API, which is free and requires no API key.
 *
 * Open-Meteo only matches a bare place name, so a stored destination such as
 * "Kuala Lumpur, Selangor, Malaysia" is retried segment by segment, narrowing
 * from the city outwards, before the lookup is treated as a miss.
 */
const geocodeLocation = async (locationName) => {
  const candidates = [
    locationName,
    ...locationName.split(',').map((part) => part.trim()),
  ].filter((candidate, index, all) => candidate && all.indexOf(candidate) === index);

  for (const candidate of candidates) {
    const match = await search(candidate);
    if (match) {
      const { latitude, longitude, name, country } = match;
      return { latitude, longitude, name, country };
    }
  }

  throw new Error(`Location not found: ${locationName}`);
};

module.exports = { geocodeLocation };
