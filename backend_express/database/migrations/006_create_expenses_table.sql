CREATE TABLE IF NOT EXISTS expenses (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  trip_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(255) NOT NULL,
  amount DECIMAL(12, 2) NOT NULL,
  currency VARCHAR(10) DEFAULT 'MYR',
  category ENUM('food', 'transport', 'accommodation', 'activity', 'shopping', 'other') DEFAULT 'other',
  expense_date DATE NOT NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
);
