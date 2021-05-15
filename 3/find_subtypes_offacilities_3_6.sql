CREATE OR REPLACE FUNCTION find_subtypes_offacilities_3_6(nameOfFacility varchar) RETURNS TABLE("Name Of Subfacility" varchar)
AS
$$
DECLARE 
	numofsubfs integer;
	namevar varchar;
BEGIN
DROP TABLE IF EXISTS subfacilities;
DROP TABLE IF EXISTS finalOutput;
CREATE TEMP TABLE subfacilities(namefacil varchar);
CREATE TEMP TABLE finalOutput(namefacil varchar);

IF((SELECT "subtypeOf" FROM facility WHERE "nameFacility" = nameOfFacility) IS NOT NULL) THEN
	RAISE EXCEPTION 'Please only search for head facilities!';
END IF;

INSERT INTO subfacilities(SELECT "nameFacility" FROM facility WHERE "subtypeOf"=nameOfFacility AND "type"='hotel' ORDER BY "nameFacility");
INSERT INTO finalOutput(SELECT * FROM subfacilities);
numofsubfs = COUNT(*) FROM subfacilities;
						  
FOR i in 1..numofsubfs-1 LOOP
	namevar = namefacil FROM subfacilities LIMIT 1 OFFSET i;
	INSERT INTO finalOutput(SELECT "nameFacility" FROM facility WHERE "subtypeOf"=namevar ORDER BY "nameFacility");						   
END LOOP;
	
	RETURN QUERY
	SELECT * FROM finalOutput;
						   
END;
$$
LANGUAGE "plpgsql";


--Test Query
--Uncomment and select the query below to test the function after it has been created

--SELECT * FROM find_subtypes_offacilities_3_6('Business Services')