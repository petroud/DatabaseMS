CREATE OR REPLACE FUNCTION calculate_completeness_4_5(hotelid integer,yearArg integer) RETURNS TABLE("Month" text, "Completeness Percentage" double precision)
AS 
$$
DECLARE
	num_of_rooms integer;
	monthno double precision;
BEGIN
	num_of_rooms = COUNT(*) FROM "room" WHERE "idHotel"=hotelid;

	RETURN QUERY
	SELECT CONCAT((TO_CHAR(TO_DATE((select extract(month from "checkin"))::text, 'MM'), 'Month')),' ',yearArg) AS "Month", 
	
		SUM(checkout-checkin)*100/(DATE_PART('days',DATE_TRUNC('month',CAST(CONCAT(yearArg,'-',LPAD((select EXTRACT(MONTH FROM "checkin"))::text,2,'0'),'-05') AS date)) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL)*num_of_rooms) AS "Completeness Percentage" 
	
	FROM find_roombookings_of_hotel(hotelid) 
	WHERE ((SELECT EXTRACT(YEAR FROM "checkin")) = yearArg)
	GROUP BY (SELECT EXTRACT(MONTH FROM "checkin"));
	

END;
$$
LANGUAGE "plpgsql";


--Test Query
--Uncomment and select the query below to test the function after it has been created
--SELECT * FROM calculate_completeness_4_5(15,2021)

--function checked
