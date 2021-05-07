CREATE FUNCTION find_max_discount_rooms_of_hotels_3_3() returns table("Hotel Name" varchar, "Hotel ID" integer, "Room type" varchar,"Discount %" real) 
AS
$$
BEGIN

	RETURN QUERY
	
	SELECT "hotel"."name", derTbl."idHotel", derTbl."roomtype",derTbl."discount" FROM
		(SELECT org."idHotel",org."roomtype",org."discount" FROM 
			(SELECT "idHotel", MAX(discount) as max_discount FROM "roomrate" GROUP BY "idHotel") as maxTable
		INNER JOIN "roomrate" as org
		ON org."idHotel" = maxTable."idHotel" AND org."discount" = maxTable.max_discount) AS derTbl
	INNER JOIN "hotel"
	ON "hotel"."idHotel" = derTbl."idHotel"
	ORDER BY derTbl."roomtype",derTbl."idHotel";

	END
$$
LANGUAGE "plpgsql";


--Test Query
--Uncomment and select the query below to test the function after it has been created

--SELECT * FROM find_max_discount_rooms_of_hotels_3_3();