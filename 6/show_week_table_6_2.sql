CREATE OR REPLACE FUNCTION show_week_table_6_2(idhotel integer) RETURNS TABLE("Day Of Week" weekday_type, "Room Number" integer,"Rate" real,"Discount" real, "Client Document" varchar, "Client ID" integer)
AS
$$
DECLARE
	startdate date;
	enddate date;
	numofbookings integer;

BEGIN
DROP TABLE IF EXISTS temptable;
DROP TABLE IF EXISTS temptable_2;

CREATE TEMP TABLE temptable(dayname weekday_type, rid integer, rate real,discount real, docli varchar, cliid integer);
CREATE TEMP TABLE temptable_2(idr integer,idnr integer, rt real, ds real, idhtl integer, docclient varchar, clientid integer);
	
	SELECT "startd","endd" INTO "startdate","enddate" FROM find_next_week();
	numofbookings = COUNT (*) FROM get_week_bookings_6_2(startdate,enddate,idhotel);
					
	INSERT INTO temptable_2 (SELECT * FROM get_week_bookings_6_2(startdate,enddate,idhotel));
	
	FOR i in 1..7 LOOP	
		FOR j in 1..numofbookings-1 LOOP
			INSERT INTO temptable (SELECT convertinttoday(i) AS dayname,
								   (SELECT idnr FROM temptable_2 LIMIT 1 OFFSET j),
								   (SELECT rt FROM temptable_2 LIMIT 1 OFFSET j),
								   (SELECT ds FROM temptable_2 LIMIT 1 OFFSET j),
								   (SELECT docclient FROM temptable_2 LIMIT 1 OFFSET j),
								   (SELECT clientid FROM temptable_2 LIMIT 1 OFFSET j)
								  );
		END LOOP;	
	END LOOP;
	
	RETURN QUERY
	SELECT * FROM temptable;
END;
$$
LANGUAGE "plpgsql";







CREATE OR REPLACE FUNCTION get_week_bookings_6_2(sdate date, edate date,idhtl integer) RETURNS TABLE(idroom integer, number integer, rate real, discount real, idhotel integer, docclient varchar, clienti integer)
AS
$$
BEGIN

RETURN QUERY

SELECT hrooms.idroom,hrooms.number,roomrate.rate,roomrate.discount,hrooms.idhotel,CASE
                   							 WHEN "clientid" IS NULL THEN '0'
                    						 ELSE "documentclient"
               							   END AS "docclient", "clientid"
FROM get_hotel_rooms(idhtl) as hrooms
LEFT JOIN 
	(SELECT * FROM find_detailedbookings_of_hotel(idhtl)
	INNER JOIN find_next_week() as dertbl
	ON "checkin" >= sdate AND "checkin" <= edate) as weekbooks
ON hrooms."idroom" = weekbooks."roomid"
INNER JOIN "roomrate" on "roomrate"."roomtype" = "hrooms"."roomtype" AND "roomrate"."idHotel" = hrooms."idhotel"
LEFT JOIN "client" ON "client"."idClient" = clientid
ORDER BY "idroom";


END;
$$
LANGUAGE "plpgsql";





CREATE VIEW view_hotel_weektable_6_2 AS
SELECT * FROM show_week_table_6_2(20);