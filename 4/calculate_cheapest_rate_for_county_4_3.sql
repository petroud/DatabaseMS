CREATE FUNCTION calculate_cheapest_rate_for_country_4_3(countryname varchar) RETURNS TABLE("Roomtype" varchar,"Cheapest Rate" real,"Hotel ID" integer,"City" varchar)
AS
$$
BEGIN

RETURN QUERY
SELECT DISTINCT ON("roomtype") "roomtype", MIN("rate"),"roomrate"."idHotel","countryHotels"."city" FROM "roomrate"
INNER JOIN (SELECT * FROM "hotel" WHERE "country" = countryname) as "countryHotels"
ON "roomrate"."idHotel" = "countryHotels"."idHotel"
GROUP BY "roomtype","roomrate"."idHotel","countryHotels"."city"
ORDER BY "roomtype","rate" ASC;


END;
$$
LANGUAGE "plpgsql";

--Test Query
--Uncomment and select the query below to test the function after it has been created
--SELECT * FROM calculate_cheapest_rate_for_country_4_3('Russia');

--function checked