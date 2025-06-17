/*
OVERALL OBJECTIVE:
This SQL script explores and analyzes water service data to:
1. Investigate water source infrastructure and types
2. Assess service visit patterns and queue times
3. Evaluate water quality metrics
4. Identify and correct data quality issues in well pollution records
The analysis helps identify problematic water sources, long wait times,
and ensures accurate contamination reporting for public health purposes.
*/

-- Initial database setup - Select the water services database and list available tables --
USE md_water_services;
SHOW TABLES;

-- Data exploration - View sample records from location table to understand geographical distribution --
SELECT * FROM md_water_services.location
LIMIT 5;

-- Service analysis - Examine visit records to understand service patterns --
SELECT * FROM md_water_services.visits
LIMIT 5;

-- Source inventory - Review water source types and characteristics (note: timestamp appears out of sequence) --
SELECT * FROM md_water_services.water_source
LIMIT 5;

-- Source classification - Identify all distinct types of water sources in the system --
SELECT DISTINCT type_of_water_source
FROM md_water_services.water_source;

-- Service delays - Find extreme cases where users waited over 500 minutes in queue --
SELECT * FROM md_water_services.visits
WHERE time_in_queue > 500;

-- Specific source inspection - Retrieve detailed information about two particular water sources --
SELECT * FROM md_water_services.water_source
WHERE source_id = "AkRu05234224"
   OR source_id = "HaZa21742224";
    
-- Quality assessment - Initial review of water quality testing results --
SELECT * FROM md_water_services.water_quality;

-- Excellent quality cases - Find instances where water received perfect scores on second visits --
SELECT * FROM md_water_services.water_quality
WHERE subjective_quality_score = 10
  AND visit_count = 2;
	
-- Pollution baseline - Examine well pollution records to understand contamination data --
SELECT * FROM md_water_services.well_pollution
LIMIT 5;

-- Data quality check - Identify potentially misclassified well records where biological contamination exists but marked clean --
SELECT * FROM md_water_services.well_pollution
WHERE biological > 0.01
  AND results = "Clean"
  AND description LIKE "Clean%";

-- Data correction - Fix inaccurate well pollution records --
-- First disable safe update mode to allow batch updates --
SET SQL_SAFE_UPDATES = 0;

-- Standardize descriptions by removing incorrect 'Clean' labels --
UPDATE well_pollution
SET description = 'Bacteria: E. coli'
WHERE description = 'Clean Bacteria: E. coli';

UPDATE well_pollution
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';

-- Correct classification for biologically contaminated wells --
UPDATE well_pollution
SET results = 'Contaminated: Biological'
WHERE biological > 0.01 AND results = 'Clean';
