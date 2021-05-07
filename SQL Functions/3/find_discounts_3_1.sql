CREATE FUNCTION find_discounts_3_1() RETURNS TABLE("City" varchar,"Country" varchar)
AS
$$
BEGIN
	RETURN QUERY
	SELECT DISTINCT "city", "country" FROM "hotel"
	INNER JOIN (SELECT DISTINCT "idHotel" FROM "roomrate" WHERE "discount">=30) AS "derTbl"
	ON "hotel"."idHotel" = "derTbl"."idHotel";

END;
$$
LANGUAGE "plpgsql";

--Test Query
--Uncomment and select the query below to test the function after it has been created
--SELECT * FROM find_discounts_3_1();