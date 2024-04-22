CREATE DATABASE IF NOT EXISTS iaas_db; USE iaas_db; CREATE TABLE IF NOT EXISTS iaas_table (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255) NOT NULL, description TEXT);

INSERT INTO iaas_table (name, description) SELECT * FROM (SELECT 'Fun Fact 1' AS name, 'Over 75% of SAP’s Employees Are Shareholders.' AS description UNION ALL SELECT 'Fun Fact 2', 'The Employees of SAP Are From 157 Countries.' UNION ALL SELECT 'Fun Fact 3', 'The Employee’s Retention Rate At SAP Stands at 94.8%') AS tmp WHERE NOT EXISTS (SELECT * FROM iaas_table);
