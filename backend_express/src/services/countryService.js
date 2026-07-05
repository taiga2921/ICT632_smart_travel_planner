const axios = require('axios');

const getCountryInfo = async (countryName) => {
  const response = await axios.get(
    `https://restcountries.com/v3.1/name/${encodeURIComponent(countryName)}`
  );
  const country = response.data[0];
  return {
    name: country.name?.common,
    officialName: country.name?.official,
    capital: country.capital?.[0],
    region: country.region,
    currencies: country.currencies,
    languages: country.languages,
    timezones: country.timezones,
    flag: country.flags?.png,
    population: country.population,
  };
};

module.exports = { getCountryInfo };
