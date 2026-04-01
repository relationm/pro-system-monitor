-- Database initialization for System Monitor
CREATE DATABASE IF NOT EXISTS system_monitor;
USE system_monitor;

-- Table for registered servers
CREATE TABLE IF NOT EXISTS servers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hostname VARCHAR(255) NOT NULL,
    api_key VARCHAR(64) NOT NULL UNIQUE, 
    ip_address VARCHAR(45) DEFAULT NULL, 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Table for time-series metrics
CREATE TABLE IF NOT EXISTS metrics (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    server_id INT NOT NULL,
    cpu_usage_percent DECIMAL(5, 2) NOT NULL,
    load_average DECIMAL(5, 2) NOT NULL,
    memory_free_mb INT NOT NULL,
    disk_free_gb DECIMAL(8, 2) NOT NULL,
    iowait_percent DECIMAL(5, 2) NOT NULL,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (server_id) REFERENCES servers(id) ON DELETE CASCADE,
    INDEX idx_server_time (server_id, recorded_at)
) ENGINE=InnoDB;

-- Insert a default demo server for testing
INSERT INTO servers (hostname, api_key) VALUES ('demo-server', 'test-token-123');