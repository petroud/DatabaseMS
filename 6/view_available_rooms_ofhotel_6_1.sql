CREATE VIEW view_available_rooms_ofhotels_6_1 AS

SELECT DISTINCT ON (dd."idRoom") dd."idRoom" as "Room ID","checkin" as "Available Until","roomtype" as "Type","idHotel" FROM

    (SELECT "idRoom",CASE WHEN "checkin" IS NULL THEN '9999-12-31' ELSE "checkin" END,"roomtype","checkout","idHotel" FROM "roombooking" 
    RIGHT JOIN "room" ON "roombooking"."roomID" = "room"."idRoom"
    ORDER BY "checkin" ASC) as dd

WHERE (NOT NOW()::date BETWEEN checkin AND checkout) OR (checkin IS NULL)
ORDER BY "idRoom","checkin" ASC


--Test Query
--Uncomment and select the query below to test the view after it has been created
--SELECT * FROM view_available_rooms_of_hotels_6_1()