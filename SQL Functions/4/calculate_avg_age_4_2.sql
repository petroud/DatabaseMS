CREATE FUNCTION calculate_avg_age_4_2(roomtypearg varchar) returns table("Age In Years" double precision, "Info" text)
AS
$$
BEGIN

RETURN QUERY
SELECT AVG(ages."Age in Years"), CONCAT('Room Type : ',roomtypearg) from
(SELECT *, DATE_PART('year', NOW()) - DATE_PART('year', dates."dateofbirth") AS "Age in Years"
from
(SELECT "dateofbirth" FROM "person" 
					 INNER JOIN
						(SELECT * FROM "roombooking" INNER JOIN (SELECT * FROM "room" WHERE "roomtype" = roomtypearg) as roomTbl
					 ON "roombooking"."roomID" = roomTbl."idRoom") as typeBookings
					 ON "person"."idPerson" = typeBookings."bookedforpersonID") as dates) as ages;

END;
$$
LANGUAGE "plpgsql";



--Test Query
--Uncomment and select the query below to test the function after it has been created
--SELECT * FROM calculate_avg_age_4_2('Cabana')

--function checked
