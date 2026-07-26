const axios = require('axios');

const getCountryInfo = async (countryName) => {
  const response = await axios.get(
    `https://restcountries.com/v3.1/name/${encodeURIComponent(countryName)}`
  );

  if (!Array.isArray(response.data) || response.data.length === 0) {
    throw new Error(`Country not found: ${countryName}`);
  }

  const country = response.data[0];

  if (!country || !country.name) {
    throw new Error(`Invalid country data for: ${countryName}`);
  }

  return {
    name: country.name?.common ?? null,
    officialName: country.name?.official ?? null,
    capital: country.capital?.[0] ?? null,
    region: country.region ?? null,
    currencies: country.currencies ?? null,
    languages: country.languages ?? null,
    timezones: country.timezones ?? null,
    flag: country.flags?.png ?? null,
    population: country.population ?? null,
  };
};

module.exports = { getCountryInfo };
