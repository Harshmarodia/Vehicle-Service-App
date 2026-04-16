/**
 * Simple in-memory storage for live locations.
 * In production, use Redis.
 */
const mechanicLocations = new Map();

/**
 * Update a mechanic's location
 */
exports.updateLocation = (mechanicId, latitude, longitude) => {
  mechanicLocations.set(mechanicId.toString(), {
    latitude,
    longitude,
    lastUpdate: new Date(),
  });
  return true;
};

/**
 * Get a mechanic's location
 */
exports.getLocation = (mechanicId) => {
  return mechanicLocations.get(mechanicId.toString());
};

/**
 * Calculate ETA (Simulation)
 * @param {object} origin {lat, lng}
 * @param {object} destination {lat, lng}
 */
exports.calculateETA = (origin, destination) => {
  // Heuristic: Roughly 2 mins per km, adding traffic variance
  // For now returning a random but realistic number for demo
  const baseMins = 15;
  const variance = Math.floor(Math.random() * 10);
  return `${baseMins + variance} mins`;
};
