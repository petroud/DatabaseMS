CREATE FUNCTION calculate_best_hotels_byincome_4_4() RETURNS TABLE("Hotel ID" integer,"Hotel Name" varchar,"City" varchar,"Income" numeric,"Average" double precision)
AS
$$
DECLARE
	average double precision;
BEGIN
average = AVG(income) FROM
(select DISTINCT ON("hotel"."idHotel") hotel."idHotel",hotel."name",hotel."city",SUM("transaction"."amount") as income
FROM hotel
INNER JOIN "room" ON "hotel"."idHotel" = "room"."idHotel"
INNER JOIN "roombooking" ON "roombooking"."roomID" = "room"."idRoom"
INNER JOIN "hotelbooking" ON "hotelbooking"."idhotelbooking" = "roombooking"."hotelbookingID"
INNER JOIN "transaction" ON "hotelbooking"."idhotelbooking" = "transaction"."idHotelBooking"
GROUP BY "hotel"."idHotel")as dd;

RETURN QUERY
SELECT "idHotel","name","city","income",average FROM 
(select DISTINCT ON("hotel"."idHotel") hotel."idHotel",hotel."name",hotel."city",SUM("transaction"."amount") as income
FROM hotel
INNER JOIN "room" ON "hotel"."idHotel" = "room"."idHotel"
INNER JOIN "roombooking" ON "roombooking"."roomID" = "room"."idRoom"
INNER JOIN "hotelbooking" ON "hotelbooking"."idhotelbooking" = "roombooking"."hotelbookingID"
INNER JOIN "transaction" ON "hotelbooking"."idhotelbooking" = "transaction"."idHotelBooking"
GROUP BY "hotel"."idHotel")as dd
WHERE "income">average;

END;
$$
LANGUAGE "plpgsql";
