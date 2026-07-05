CREATE TABLE IF NOT EXISTS itinerary_items (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  itinerary_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  location VARCHAR(255),
  start_time TIME,
  end_time TIME,
  type ENUM('activity', 'transport', 'food', 'accommodation', 'other') DEFAULT 'activity',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (itinerary_id) REFERENCES itineraries(id) ON DELETE CASCADE
);
