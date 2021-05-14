CREATE OR REPLACE FUNCTION find_hotel_available_type_3_8() RETURNS TABLE("Hotel Name" varchar, "Hotel ID" integer)
AS
$$
DECLARE 
	numofhotels integer;
	hotelid integer;
	hotelname varchar;
BEGIN
DROP TABLE IF EXISTS hotelsToShow;
CREATE TEMP TABLE hotelsToShow("Hotel Name" varchar, "Hotel ID" integer);

numOfHotels = COUNT(*) FROM hotel;

FOR i in 1..numOfHotels-1 LOOP
	hotelid = "idHotel" FROM hotel LIMIT 1 OFFSET i;
	hotelname = "name" FROM hotel LIMIT 1 OFFSET i;
	
	IF((SELECT COUNT(*) FROM
			(SELECT hotelrooms."roomtype",CASE
                   				WHEN "numofbookedrooms" IS NULL THEN numofhotelrooms
                    			ELSE (numofhotelrooms-numofbookedrooms)
               				    END AS "availrooms" 
			FROM((SELECT COUNT(*) AS "numofhotelrooms", roomtype FROM get_hotel_rooms(hotelid)
			group by roomtype) as hotelrooms
			LEFT JOIN
			(SELECT COUNT(*) as numofbookedrooms, roomtype FROM find_detailedbookings_of_hotel(hotelid) WHERE checkin<(SELECT NOW()) AND checkout>(SELECT NOW())
			group by roomtype) as hotelbooks
			ON hotelrooms.roomtype = hotelbooks.roomtype)) as dd
		WHERE dd."availrooms" = 0) = 0) THEN
	   		INSERT INTO hotelsToShow VALUES(hotelname,hotelid);
   END IF;
END LOOP;

RETURN QUERY 
SELECT * FROM hotelsToShow;

END;
$$
LANGUAGE "plpgsql";

--Test Query
--Uncomment and select the query below to test the function after it has been created

--SELECT * FROM find_hotel_available_type_3_8()