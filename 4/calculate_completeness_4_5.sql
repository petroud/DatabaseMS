CREATE FUNCTION calculate_completeness_4_5(hotelid integer,yearArg integer) RETURNS TABLE("Month" text, "Completeness Percentage" bigint)
AS 
$$
DECLARE
	num_of_rooms integer;
BEGIN
	num_of_rooms = COUNT(*) FROM "room" WHERE "idHotel"=hotelid;

	RETURN QUERY
	SELECT CONCAT((TO_CHAR(TO_DATE((select extract(month from "checkin"))::text, 'MM'), 'Month')),' ',yearArg) AS "Month" , count(DISTINCT(roomid))*100/num_of_rooms AS "Completeness Percentage" FROM find_roombookings_of_hotel(hotelid) 
	WHERE ((SELECT EXTRACT(YEAR FROM "checkin")) = yearArg)
	GROUP BY (SELECT EXTRACT(MONTH FROM "checkin"));
	

END;
$$
LANGUAGE "plpgsql";


--Test Query
--Uncomment and select the query below to test the function after it has been created
--SELECT * FROM calculate_completeness_4_5(15,2021)

--function checked
