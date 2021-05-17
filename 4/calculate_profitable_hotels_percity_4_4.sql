CREATE OR REPLACE FUNCTION calculate_profitable_hotels_percity_4_4() RETURNS TABLE("City" varchar, "Hotel Name" varchar, "Hotel ID" integer, "Income" numeric, "City Average" numeric)
AS
$$
BEGIN

RETURN QUERY
WITH cityAvg(cityname,avgIncomeOfCity) AS(SELECT city, AVG(income) as averagePerCity FROM
(select DISTINCT ON("hotel"."idHotel") hotel."idHotel",hotel."name",hotel."city",SUM("transaction"."amount") as income
FROM hotel
INNER JOIN "room" ON "hotel"."idHotel" = "room"."idHotel"
INNER JOIN "roombooking" ON "roombooking"."roomID" = "room"."idRoom"
INNER JOIN "hotelbooking" ON "hotelbooking"."idhotelbooking" = "roombooking"."hotelbookingID"
INNER JOIN "transaction" ON "hotelbooking"."idhotelbooking" = "transaction"."idHotelBooking"
GROUP BY "hotel"."idHotel") AS DD
GROUP BY city),

hotelsIncome(hotelid, hotelname, hotelcity, hotelincome) AS (select DISTINCT ON("hotel"."idHotel") hotel."idHotel",hotel."name",hotel."city",SUM("transaction"."amount") as income
FROM hotel
INNER JOIN "room" ON "hotel"."idHotel" = "room"."idHotel"
INNER JOIN "roombooking" ON "roombooking"."roomID" = "room"."idRoom"
INNER JOIN "hotelbooking" ON "hotelbooking"."idhotelbooking" = "roombooking"."hotelbookingID"
INNER JOIN "transaction" ON "hotelbooking"."idhotelbooking" = "transaction"."idHotelBooking"
GROUP BY "hotel"."idHotel")


SELECT hotelcity, hotelname,hotelid,hotelincome,avgincomeofcity FROM hotelsIncome
INNER JOIN cityAvg 
ON cityAvg."cityname" = hotelsIncome."hotelcity"
WHERE hotelsIncome.hotelincome>=cityAvg.avgIncomeOfCity;

END;
$$
LANGUAGE "plpgsql";

--Test Query
--Uncomment and select the query below to test the function after it has been created
--SELECT * FROM calculate_profitable_hotels_percity_4_4()