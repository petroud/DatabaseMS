CREATE FUNCTION find_hotel_bookings_3_4(hotelIDarg integer) returns table("Hotel Booking ID" integer, "Client Name" varchar, "Reservation Date" date,"Booked By" varchar) 
AS
$$
BEGIN

	RETURN QUERY
	
	SELECT (hbookings."idhotelbooking") AS "Hotel Booking ID", (SELECT get_name_by_id(hbookings."bookedforpersonID")) AS "Client Name", hbookings.reservationdate AS "Reservation Date", (SELECT checkifclient("bookedbyclientID") AS "Booked By")
	FROM (SELECT * FROM room
	INNER JOIN (SELECT * FROM hotelbooking INNER JOIN roombooking ON hotelbooking.idhotelbooking = roombooking."hotelbookingID") AS bookings
	ON room."idRoom" = bookings."roomID" WHERE room."idHotel" = hotelIDarg) as hbookings
	ORDER BY idhotelbooking;
	
	END;
$$
LANGUAGE "plpgsql";

--Test Query
--Uncomment and select the query below to test the function after it has been created

--SELECT * from find_hotel_bookings_3_4(15);

--function checked