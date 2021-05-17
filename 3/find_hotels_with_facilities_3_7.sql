CREATE OR REPLACE FUNCTION public.find_hotels_with_facilities_3_7(
	roomheadfacil character varying, hotelheadfacil character varying)
    RETURNS TABLE("Hotel ID" integer, "Hotel Name" character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN	
		
	RETURN QUERY
	WITH matchedHotels(idhotel) AS (SELECT DISTINCT "idHotel" FROM "roomfacilities" 
		INNER JOIN
			(SELECT "idHotel","idRoom" FROM room
			INNER JOIN (SELECT DISTINCT "roomID" FROM roombooking WHERE checkin<(SELECT NOW()) AND checkout>(SELECT NOW())) as freerooms
			ON "room"."idRoom" = freerooms."roomID") as availHotels
		ON "roomfacilities"."idRoom"= availHotels."idRoom"
		
		INNER JOIN "facility" 
		ON "facility"."nameFacility" = "roomfacilities"."nameFacility" 
		WHERE roomfacilities."nameFacility" = roomheadfacil OR "subtypeOf"=roomheadfacil),
	
	capableHotels(idh,namee) AS (SELECT DISTINCT "hotel"."idHotel","hotel"."name" FROM "hotel"
						   INNER JOIN "hotelfacilities" ON hotelfacilities."idHotel" = "hotel"."idHotel"
						   INNER JOIN "facility" ON "facility"."nameFacility" = "hotelfacilities"."nameFacility"
						   WHERE "facility"."nameFacility" = hotelheadfacil OR "facility"."subtypeOf" =  hotelheadfacil
						   ORDER BY "hotel"."idHotel")
		
	
	SELECT idh,namee FROM capableHotels INNER JOIN matchedHotels ON matchedHotels."idhotel" = capableHotels."idh";

END;
$BODY$;



--Test Query
--Uncomment and select the query below to test the function after it has been created
--SELECT * FROM find_hotels_with_facilities_3_7('Beverages & Drinks','Business Services')