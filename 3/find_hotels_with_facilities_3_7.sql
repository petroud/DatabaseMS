CREATE OR REPLACE FUNCTION find_room_facilities(hid integer, roomheadfacil varchar) RETURNS TABLE ("Hotel ID" integer, "Hotel Name" varchar)
AS
$$
BEGIN	
	IF((SELECT COUNT(*) FROM
		(SELECT "idRoom","roomfacilities"."nameFacility","idhotel","subtypeOf" FROM "roomfacilities" 
		INNER JOIN
			(SELECT * FROM get_hotel_rooms(hid) as rooms
			LEFT JOIN
				(SELECT DISTINCT roomid FROM find_detailedbookings_of_hotel(hid) WHERE checkin<(SELECT NOW()) AND checkout>(SELECT NOW())) as bookings
			ON rooms.idroom = bookings.roomid WHERE bookings.roomid IS NULL) AS DD
		ON DD.idroom = roomfacilities."idRoom"
		INNER JOIN "facility" ON "facility"."nameFacility" = "roomfacilities"."nameFacility") AS dertbl WHERE "nameFacility"=roomheadfacil OR "subtypeOf"=roomheadfacil)>0 ) THEN
		
		RETURN QUERY
		SELECT hid,name FROM hotel WHERE "idHotel" = hid;
	END IF;
END;
$$
LANGUAGE "plpgsql";



CREATE OR REPLACE FUNCTION find_hotels_with_facilities_3_7(hotelheadfacil varchar, roomheadfacil varchar) RETURNS TABLE("Hotel Name" varchar, "Hotel ID" integer)
AS
$$
DECLARE
	numofhotels integer;
	idht integer;
BEGIN
DROP TABLE IF EXISTS hotels;
DROP TABLE IF EXISTS matchedHotels;
CREATE TEMP TABLE hotels(idh integer);
CREATE TEMP TABLE matchedHotels(idhtl integer);

INSERT INTO hotels(SELECT DISTINCT("idHotel") FROM hotelfacilities
				   INNER JOIN "facility" ON "hotelfacilities"."nameFacility" = "facility"."nameFacility"
				   WHERE hotelfacilities."nameFacility" = hotelheadfacil OR "facility"."subtypeOf"=hotelheadfacil
				  );
numofhotels = COUNT(*) FROM hotels;

FOR i IN 1..numofhotels-1 LOOP
	idht = idh FROM hotels LIMIT 1 OFFSET i;
	INSERT INTO matchedHotels(SELECT mtchtls."Hotel ID" FROM find_room_facilities(idht,roomheadfacil) as mtchtls);
END LOOP;
	
	RETURN QUERY
	SELECT name, "idHotel" FROM hotel
	INNER JOIN matchedHotels 
	ON "hotel"."idHotel" = matchedHotels.idhtl;

END;
$$
LANGUAGE "plpgsql";