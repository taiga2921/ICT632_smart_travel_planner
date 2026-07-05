/**
 * Shared application constants.
 */

const USER_ROLES = {
  USER: 'user',
  ADMIN: 'admin',
};

const TRIP_STATUS = {
  PLANNED: 'planned',
  ONGOING: 'ongoing',
  COMPLETED: 'completed',
};

const ITINERARY_ITEM_TYPES = ['activity', 'transport', 'food', 'accommodation', 'other'];

const EXPENSE_CATEGORIES = ['food', 'transport', 'accommodation', 'activity', 'shopping', 'other'];

module.exports = {
  USER_ROLES,
  TRIP_STATUS,
  ITINERARY_ITEM_TYPES,
  EXPENSE_CATEGORIES,
};
