-- schema for pbx-scheduler-paging (MySQL/MariaDB)
CREATE TABLE zones (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE endpoints (
  id INT AUTO_INCREMENT PRIMARY KEY,
  zone_id INT,
  sip_channel VARCHAR(100) NOT NULL, -- e.g. SIP/1000
  display_name VARCHAR(100),
  last_seen TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (zone_id) REFERENCES zones(id) ON DELETE SET NULL
);

CREATE TABLE operators (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) NOT NULL,
  display_name VARCHAR(100),
  can_live_page BOOLEAN DEFAULT FALSE,
  can_manage_playlists BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tracks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  filename VARCHAR(255) NOT NULL,
  original_name VARCHAR(255),
  format VARCHAR(50),
  duration_seconds INT,
  size_bytes BIGINT,
  uploaded_by VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE playlists (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE playlist_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  playlist_id INT NOT NULL,
  track_id INT NOT NULL,
  sort_order INT DEFAULT 0,
  FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE CASCADE,
  FOREIGN KEY (track_id) REFERENCES tracks(id) ON DELETE CASCADE
);

CREATE TABLE schedule_rules (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  playlist_id INT,
  start_time TIME,
  end_time TIME,
  days_mask SMALLINT,
  specific_date DATE NULL,
  zones_json TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE SET NULL
);

CREATE TABLE azan_settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  city VARCHAR(100),
  latitude DECIMAL(9,6),
  longitude DECIMAL(9,6),
  timezone VARCHAR(50),
  play_fajr BOOLEAN DEFAULT TRUE,
  play_dhuhr BOOLEAN DEFAULT TRUE,
  play_asr BOOLEAN DEFAULT TRUE,
  before_audio_track_id INT NULL,
  after_audio_track_id INT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (before_audio_track_id) REFERENCES tracks(id),
  FOREIGN KEY (after_audio_track_id) REFERENCES tracks(id)
);

CREATE TABLE logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  level VARCHAR(10),
  component VARCHAR(50),
  message TEXT,
  meta JSON NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user VARCHAR(100),
  action VARCHAR(100),
  target_type VARCHAR(50),
  target_id INT,
  details TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);