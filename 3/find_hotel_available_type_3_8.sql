CREATE OR REPLACE FUNCTION find_hotel_available_type_3_8() RETURNS TABLE("Hotel Name" varchar, "Hotel ID" integer)
AS
$$
BEGIN

	RETURN QUERY
	SELECT "name","idHotel" FROM "hotel" WHERE 
	   (SELECT COUNT(*) FROM
			(SELECT hotelrooms."roomtype",CASE
                   				WHEN "numofbookedrooms" IS NULL THEN numofhotelrooms
                    			ELSE (numofhotelrooms-numofbookedrooms)
               				    END AS "availrooms" 
			FROM((SELECT COUNT(*) AS "numofhotelrooms", roomtype FROM get_hotel_rooms("idHotel")
			group by roomtype) as hotelrooms
			LEFT JOIN
			(SELECT COUNT(*) as numofbookedrooms, roomtype FROM find_detailedbookings_of_hotel("idHotel") WHERE checkin<(SELECT NOW()) AND checkout>(SELECT NOW())
			group by roomtype) as hotelbooks
			ON hotelrooms.roomtype = hotelbooks.roomtype)) as dd
		WHERE dd."availrooms" = 0)=0; 
END;
$$
LANGUAGE "plpgsql";

--Test Query
--Uncomment and select the query below to test the function after it has been created

--SELECT * FROM find_hotel_available_type_3_8()