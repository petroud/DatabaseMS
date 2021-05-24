CREATE OR REPLACE FUNCTION public.show_week_table_6_2(
	idhotel integer)
    RETURNS TABLE("Day Of Week" weekday_type, "Room Number" integer, "Rate" real, "Discount" real, "Client Document" character varying, "Client ID" integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
	startdate date;
	enddate date;
	numofbookings integer;

BEGIN
DROP TABLE IF EXISTS temptable;
DROP TABLE IF EXISTS temptable_2;

CREATE UNLOGGED TABLE temptable(dayname weekday_type, rid integer, rate real,discount real, docli varchar, cliid integer);
CREATE UNLOGGED TABLE temptable_2(idr integer,idnr integer, rt real, ds real, idhtl integer, docclient varchar, clientid integer);
	
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

    DROP TABLE IF EXISTS temptable;
    DROP TABLE IF EXISTS temptable_2;
END;
$BODY$;




CREATE OR REPLACE FUNCTION public.get_week_bookings_6_2(
	sdate date,
	edate date,
	idhtl integer)
    RETURNS TABLE(idroom integer, number integer, rate real, discount real, idhotel integer, docclient character varying, clienti integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
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
$BODY$;




CREATE VIEW view_hotel_weektable_6_2 AS
SELECT * FROM show_week_table_6_2(20);





CREATE TRIGGER weektable_updater_6_2
INSTEAD OF UPDATE ON view_hotel_weektable_6_2
FOR EACH ROW
EXECUTE PROCEDURE save_weektable_changes_6_2();

--Test Query
--Uncomment and select the query below to test the function after it has been created
--UPDATE view_hotel_weektable_6_2
--SET "Rate" = 1000 WHERE "Room Number"=203;

--UPDATE view_hotel_weektable_6_2
--SET "Discount" = 15 WHERE "Room Number"=203;

--UPDATE view_hotel_weektable_6_2
--SET "Client Document" = 1967657373 WHERE "Room Number"=2015 AND "Day Of Week" = 'Monday';




CREATE FUNCTION public.save_weektable_changes_6_2()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
        idhotelb integer;
BEGIN
	--Rate or Discount changed
	IF(OLD."Rate"<>NEW."Rate" OR OLD."Discount"<>NEW."Discount") THEN
		UPDATE roomrate SET rate = (NEW."Rate") , discount = (NEW."Discount") WHERE
		"idHotel" = 20 AND roomtype = (SELECT roomtype FROM room WHERE number=NEW."Room Number");
	END IF;

	--Old client was null
	IF(OLD."Client Document" <> NEW."Client Document" AND (OLD."Client Document"='0' OR OLD."Client Document" IS NULL)) THEN
		INSERT INTO hotelbooking(SELECT nextval('idhbooking'),NOW(),'9999-12-31'::date,null,(SELECT "idClient" FROM client WHERE "documentclient" = NEW."Client Document"),false,null,null);
		INSERT INTO roombooking(SELECT currval('idhbooking'),(SELECT "idRoom" FROM "room" WHERE number = NEW."Room Number"),(SELECT "idClient" FROM client WHERE "documentclient" = NEW."Client Document"),(SELECT startd FROM find_next_week())+2,(SELECT endd FROM find_next_week())-2,null);
		UPDATE "room" SET vacant=1 WHERE number = NEW."Room Number";
	--New client is null
	ELSIF(NEW."Client Document" IS NULL OR NEW."Client Document"='0') THEN
	    idhotelb =  "hotelbookingID" FROM roombooking WHERE  "bookedforpersonID"=(SELECT "idClient" FROM client WHERE documentclient= OLD."Client Document" AND "roomID"=(SELECT "idRoom" FROM room WHERE number=OLD."Room Number"));
	    DELETE FROM roombooking WHERE "bookedforpersonID"=(SELECT "idClient" FROM client WHERE documentclient= OLD."Client Document" AND "roomID"=(SELECT "idRoom" FROM room WHERE number=OLD."Room Number"));
		UPDATE "room" SET vacant=0 WHERE number = OLD."Room Number";
	END IF;

	RETURN NEW;
END;
$BODY$;
