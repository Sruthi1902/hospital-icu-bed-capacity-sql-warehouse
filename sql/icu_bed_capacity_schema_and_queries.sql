-- Create a new database named "HospitalDatabase"
CREATE DATABASE HospitalDatabase; -- This query creates the database to store all tables and data.

--  Verify that the database was created successfully by listing all databases
SHOW DATABASES; -- This query displays all available databases on the server.

-- Select "HospitalDatabase" as the active database to work in
USE HospitalDatabase; -- This query sets the newly created database as active for subsequent operations.

-- (Optional) Drop the database if it already exists to avoid duplicates
-- DROP DATABASE HospitalDatabase; 

--  Create the 'bed_type' table for storing bed type details
-- This table categorizes different types of beds in hospitals, with 'bed_id' as the primary key.
CREATE TABLE bed_type (
    bed_id INT NOT NULL PRIMARY KEY, -- Unique identifier for each bed type.
    bed_code VARCHAR(15), -- Short code for each bed type (e.g., "ICU").
    bed_desc VARCHAR(255) -- Detailed description of the bed type.
);

--  Verify the creation of 'bed_type' table by selecting all rows
SELECT * FROM bed_type; -- Displays the contents of the 'bed_type' table.

--  Create the 'business' table for storing hospital details
-- This table contains information about hospitals and their bed capacity, with 'ims_org_id' as the primary key.
CREATE TABLE business (
    ims_org_id VARCHAR(50) NOT NULL PRIMARY KEY, -- Unique identifier for each hospital.
    hospital_name VARCHAR(255), -- Name of the hospital or medical center.
    ttl_license_beds INT, -- Total number of licensed beds in the hospital.
    ttl_census_beds INT, -- Total number of census beds currently in use.
    ttl_staffed_beds INT, -- Total number of beds that are fully staffed.
	bed_cluster_id INT -- Identifier for categorizing or grouping beds within the hospital.
);

--  Verify the creation of 'business' table by selecting all rows
SELECT * FROM business; -- Displays the contents of the 'business' table.

-- Create the 'bed_fact' table for storing measurable data
-- This fact table links hospitals and bed types and contains quantitative data about bed capacities.
CREATE TABLE bed_fact (
    fact_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, -- Unique identifier for each row in the table (auto-incremented).
    ims_org_id VARCHAR(50), -- Foreign key referencing the unique hospital ID.
    bed_id INT, -- Foreign key referencing the unique bed type ID.
    license_beds INT, -- Number of licensed beds for a specific bed type in the hospital.
    census_beds INT, -- Number of beds currently in use for a specific bed type in the hospital.
    staffed_beds INT, -- Number of beds that are fully staffed and operational for the given type.
    FOREIGN KEY (ims_org_id) REFERENCES business(ims_org_id), -- Ensures referential integrity with the 'business' table.
    FOREIGN KEY (bed_id) REFERENCES bed_type(bed_id) -- Ensures referential integrity with the 'bed_type' table.
);

-- Verify the creation of 'bed_fact' table by selecting all rows 
SELECT * FROM bed_fact; -- Displays the contents of the 'bed_fact' table.

-- Checking for duplicate organization IDs in the 'business' table
-- This query groups records by 'ims_org_id' and filters those with a count greater than 1.
SELECT ims_org_id, COUNT(*) AS duplicate_count
FROM business
GROUP BY ims_org_id
HAVING COUNT(*) > 1;

-- Checking for duplicate hospital names in the 'business' table
-- This query groups hospitals by their name and returns those that appear more than once.
SELECT hospital_name, COUNT(*) AS occurrence_count
FROM business
GROUP BY hospital_name
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;

-------------------------------------------------------------------

-- Answering Business Questions 

-- Query 1: Identifying the top 10 hospitals with the highest number of licensed beds in ICU and SICU units.
-- This query retrieves hospitals with the most licensed ICU and SICU beds while also including census and staffed beds for reference.
SELECT 
    MIN(f.ims_org_id) AS org_id,  -- Retrieves the minimum organization ID for uniqueness
    b.hospital_name,  -- Retrieves the hospital name
    SUM(f.license_beds) AS Total_Licensed_Beds,  -- Sums the total licensed beds available in ICU and SICU units
    SUM(CASE WHEN t.bed_desc = 'ICU' THEN f.license_beds ELSE 0 END) AS LicBeds_ICU, -- Filters licensed ICU beds
    SUM(CASE WHEN t.bed_desc = 'SICU' THEN f.license_beds ELSE 0 END) AS LicBeds_SICU, -- Filters licensed SICU beds
    SUM(CASE WHEN t.bed_desc = 'ICU' THEN f.census_beds ELSE 0 END) AS CensBeds_ICU, -- Filters census ICU beds
    SUM(CASE WHEN t.bed_desc = 'SICU' THEN f.census_beds ELSE 0 END) AS CensBeds_SICU, -- Filters census SICU beds
    SUM(CASE WHEN t.bed_desc = 'ICU' THEN f.staffed_beds ELSE 0 END) AS StaffBeds_ICU, -- Filters staffed ICU beds
    SUM(CASE WHEN t.bed_desc = 'SICU' THEN f.staffed_beds ELSE 0 END) AS StaffBeds_SICU -- Filters staffed SICU beds
FROM  bed_fact f
LEFT JOIN 
    business b ON b.ims_org_id = f.ims_org_id  -- Joins the business table to fetch hospital names
LEFT JOIN 
    bed_type t ON t.bed_id = f.bed_id  -- Joins the bed type table
WHERE 
    t.bed_desc = 'ICU' OR t.bed_desc = 'SICU' -- Filters only ICU and SICU beds
GROUP BY 
    b.hospital_name  -- Groups by hospital name to aggregate bed counts
ORDER BY 
    Total_Licensed_Beds DESC  -- Sorts results in descending order of total licensed beds
LIMIT 10; -- Retrieves only the top 10 hospitals




-- Query 2: Identifying the top 10 hospitals with the highest number of census beds in ICUs and SICUs.
-- This query provides insight into the actual number of beds in use at these hospitals.
SELECT 
    MIN(f.ims_org_id) AS org_id,  -- Retrieves the minimum organization ID
    b.hospital_name,  -- Retrieves the hospital name
    SUM(f.census_beds) AS Total_Census_Beds,  -- Sums the total census beds (occupied beds)
    SUM(CASE WHEN t.bed_desc = 'ICU' THEN f.license_beds ELSE 0 END) AS LicBeds_ICU, -- Filters licensed ICU beds
    SUM(CASE WHEN t.bed_desc = 'SICU' THEN f.license_beds ELSE 0 END) AS LicBeds_SICU, -- Filters licensed SICU beds
    SUM(CASE WHEN t.bed_desc = 'ICU' THEN f.census_beds ELSE 0 END) AS CensBeds_ICU, -- Filters census ICU beds
    SUM(CASE WHEN t.bed_desc = 'SICU' THEN f.census_beds ELSE 0 END) AS CensBeds_SICU, -- Filters census SICU beds
    SUM(CASE WHEN t.bed_desc = 'ICU' THEN f.staffed_beds ELSE 0 END) AS StaffBeds_ICU, -- Filters staffed ICU beds
    SUM(CASE WHEN t.bed_desc = 'SICU' THEN f.staffed_beds ELSE 0 END) AS StaffBeds_SICU -- Filters staffed SICU beds
FROM  bed_fact f
LEFT JOIN 
    business b ON b.ims_org_id = f.ims_org_id  -- Joins the business table to fetch hospital names
LEFT JOIN 
    bed_type t ON t.bed_id = f.bed_id  -- Joins the bed type table
WHERE 
    t.bed_desc = 'ICU' OR t.bed_desc = 'SICU' -- Filters only ICU and SICU beds
GROUP BY 
    b.hospital_name  -- Groups by hospital name for aggregation
ORDER BY 
    Total_Census_Beds DESC  -- Sorts in descending order based on total census beds
LIMIT 10; -- Retrieves the top 10 hospitals




-- Query 3: Identifying the top 10 hospitals with the highest number of staffed beds in ICUs and SICUs.
-- This query determines the hospitals with the most operational beds based on available staffing.
SELECT 
    MIN(f.ims_org_id) AS org_id,  -- Retrieves the minimum organization ID
    b.hospital_name,  -- Retrieves the hospital name
    SUM(f.staffed_beds) AS Total_Staffed_Beds,  -- Sums the total staffed beds
    SUM(CASE WHEN t.bed_desc = 'ICU' THEN f.license_beds ELSE 0 END) AS LicBeds_ICU, -- Filters licensed ICU beds
    SUM(CASE WHEN t.bed_desc = 'SICU' THEN f.license_beds ELSE 0 END) AS LicBeds_SICU, -- Filters licensed SICU beds
    SUM(CASE WHEN t.bed_desc = 'ICU' THEN f.census_beds ELSE 0 END) AS CensBeds_ICU, -- Filters census ICU beds
    SUM(CASE WHEN t.bed_desc = 'SICU' THEN f.census_beds ELSE 0 END) AS CensBeds_SICU, -- Filters census SICU beds
    SUM(CASE WHEN t.bed_desc = 'ICU' THEN f.staffed_beds ELSE 0 END) AS StaffBeds_ICU, -- Filters staffed ICU beds
    SUM(CASE WHEN t.bed_desc = 'SICU' THEN f.staffed_beds ELSE 0 END) AS StaffBeds_SICU -- Filters staffed SICU beds
FROM  bed_fact f
LEFT JOIN 
    business b ON b.ims_org_id = f.ims_org_id  -- Joins the business table
LEFT JOIN 
    bed_type t ON t.bed_id = f.bed_id  -- Joins the bed type table
WHERE 
    t.bed_desc = 'ICU' OR t.bed_desc = 'SICU' -- Filters only ICU and SICU beds
GROUP BY 
    b.hospital_name  -- Groups by hospital name
ORDER BY 
    Total_Staffed_Beds DESC  -- Sorts results based on total staffed beds
LIMIT 10; -- Retrieves the top 10 hospitals