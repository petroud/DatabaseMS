CREATE OR REPLACE FUNCTION calculate_profitable_hotels_percity_4_4() RETURNS TABLE("City" varchar, "Hotel Name" varchar, "Hotel ID" integer, "Income" real, "City Average" real)
AS
$$
DECLARE
	numofcities integer;
	cityAverage real;
BEGIN
DROP TABLE IF EXISTS cityAvg;
DROP TABLE IF EXISTS hotelsIncome;
DROP TABLE IF EXISTS bestHotels;

CREATE TEMP TABLE cityAvg(cityname varchar, avgIncomeOfCity real);
CREATE TEMP TABLE hotelsIncome(hotelid integer, hotelname varchar, hotelcity varchar, hotelincome real);
CREATE TEMP TABLE bestHotels("City" varchar, "Hotel Name" varchar, "Hotel ID" integer, "Income" real, "City Average" real);


INSERT INTO cityAvg (SELECT city, AVG(income) as averagePerCity FROM
(select DISTINCT ON("hotel"."idHotel") hotel."idHotel",hotel."name",hotel."city",SUM("transaction"."amount") as income
FROM hotel
INNER JOIN "room" ON "hotel"."idHotel" = "room"."idHotel"
INNER JOIN "roombooking" ON "roombooking"."roomID" = "room"."idRoom"
INNER JOIN "hotelbooking" ON "hotelbooking"."idhotelbooking" = "roombooking"."hotelbookingID"
INNER JOIN "transaction" ON "hotelbooking"."idhotelbooking" = "transaction"."idHotelBooking"
GROUP BY "hotel"."idHotel") AS DD
GROUP BY city);

INSERT INTO hotelsIncome (select DISTINCT ON("hotel"."idHotel") hotel."idHotel",hotel."name",hotel."city",SUM("transaction"."amount") as income
FROM hotel
INNER JOIN "room" ON "hotel"."idHotel" = "room"."idHotel"
INNER JOIN "roombooking" ON "roombooking"."roomID" = "room"."idRoom"
INNER JOIN "hotelbooking" ON "hotelbooking"."idhotelbooking" = "roombooking"."hotelbookingID"
INNER JOIN "transaction" ON "hotelbooking"."idhotelbooking" = "transaction"."idHotelBooking"
GROUP BY "hotel"."idHotel");

numofcities = COUNT(*) FROM cityAvg;

FOR i in 1..numofcities-1 LOOP
	cityAverage = avgIncomeOfCity FROM cityAvg LIMIT 1 OFFSET i;
	INSERT INTO bestHotels(SELECT hotelcity,hotelname,hotelid,hotelincome,cityAverage FROM hotelsIncome 
						   WHERE hotelincome>=cityAverage  
						   AND hotelcity = (SELECT cityname FROM cityAvg LIMIT 1 OFFSET i));
END LOOP;


RETURN QUERY 
SELECT * FROM bestHotels;

END;
$$
LANGUAGE "plpgsql";