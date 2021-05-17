CREATE OR REPLACE FUNCTION find_subtypes_offacilities_3_6(nameOfFacility varchar) RETURNS TABLE("Name Of Subfacility" varchar)
AS
$$
DECLARE 
	numofsubfs integer;
	namevar varchar;
BEGIN

IF((SELECT "subtypeOf" FROM facility WHERE "nameFacility" = nameOfFacility) IS NOT NULL) THEN
	RAISE EXCEPTION 'Please only search for head facilities!';
END IF;

RETURN QUERY
WITH subfacilities(namefacil) AS (SELECT "nameFacility" FROM facility WHERE "subtypeOf"=nameOfFacility AND "type"='hotel' ORDER BY "nameFacility"),
	 subsubfacilities(namefacil) AS (SELECT "nameFacility" FROM "facility" INNER JOIN "subfacilities" ON "facility"."subtypeOf" = "subfacilities"."namefacil")

SELECT * FROM subfacilities
UNION
SELECT * FROM subsubfacilities;

END;
$$
LANGUAGE "plpgsql";


--Test Query
--Uncomment and select the query below to test the function after it has been created

--SELECT * FROM find_subtypes_offacilities_3_6('Business Services')