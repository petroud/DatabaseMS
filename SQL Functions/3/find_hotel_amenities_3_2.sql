CREATE FUNCTION find_hotel_amenities_3_2(hname varchar, hasstars varchar) 
	RETURNS TABLE("Hotel Name" varchar,"Hotel ID" integer, "Stars" varchar, "City" varchar, "Country" varchar) 
AS 
$$
BEGIN
	RETURN QUERY
	
		SELECT "name","hotel"."idHotel","stars","city","country" FROM "hotel"
		INNER JOIN
			(SELECT tbl1."idHotel" FROM
				(SELECT "idHotel" FROM "roomrate"
				 WHERE "roomtype" = 'Studio' AND (rate-(discount/100)*rate)<=80) as tbl1
			INNER JOIN
				(SELECT "idHotel" FROM (SELECT "idHotel","nameFacility" FROM "hotelfacilities" WHERE "nameFacility" = 'Restaurant' OR "nameFacility" = 'Breakfast' ORDER BY "idHotel") as derTbl
				 GROUP BY "idHotel"
				HAVING COUNT(*)>1) as tbl2
			ON tbl1."idHotel" = tbl2."idHotel") as "criteriaTable"
		ON "hotel"."idHotel" = "criteriaTable"."idHotel"
		WHERE "name" LIKE CONCAT(hname,'%') AND "stars" = hasstars;
		
	
END;
$$
LANGUAGE "plpgsql";

--Test Query
--Uncomment and select the query below to test the function after it has been created

--SELECT * FROM find_hotel_amenities_3_2('Be','4');
