CREATE FUNCTION generate_bookings_2_2(idhotel integer,startdate date, enddate date, numberofbookings integer) RETURNS VOID
AS 
$$
DECLARE
	checkin_random date;
	checkout_random date;
	bookedbyid integer;
	reservation_date date;
	cancelation_date date;
	rand_client_id integer;
	rand_responsible_id integer;
	country_of_client varchar;
	hbookingid integer;
	number_of_rooms integer;
	room_id integer;
	check_not_employee boolean;
	room_responsible_id integer;
	check_overlaps boolean;

BEGIN

	reservation_date = startdate - integer '20';
	cancelation_date = startdate - integer '10';
	

	FOR i IN 1..numberofbookings LOOP
		
		--Select a random client and find the country we are working on
		LOOP
			rand_client_id = "idPerson" FROM person ORDER BY RANDOM() LIMIT 1;
			check_not_employee = COUNT(1) > 0 FROM gethotelemployees(idhotel) WHERE empid = rand_client_id;
			IF (check_not_employee = 'false') THEN 
				EXIT;
			END IF;
		END LOOP;

		country_of_client = country FROM person WHERE "idPerson" = rand_client_id;
		
		--Create a tuple in hotelbooking table about the booking we are about to construct
		hbookingid = nextval(idhbooking);
		INSERT INTO hotelbooking VALUES (hbookingid, reservation_date, cancelation_date, NULL, rand_client_id, FALSE, NULL,'confirmed');
		INSERT INTO manages VALUES(SELECT selectrandomhotelemployee(idhotel),hbookingid);

		--Randomly select the number of rooms this booking will have
		number_of_rooms = ceil(random() * 5);
		
		--For each room we are creating a roombooking tuple
		FOR i IN 1..number_of_rooms LOOP
			
			-- Check if room has already been booked for this booking
			LOOP	
				room_id =  "idRoom" FROM get_hotel_rooms(idhotel) ORDER BY RANDOM() LIMIT 1;
				EXIT WHEN (SELECT count(1)>0 FROM "roombooking" WHERE "hotelbookingID" = hbookingid AND "roomID" = room_id) = 'false';
			END LOOP;

			--Check overlaps
			LOOP	
				checkin_random = date(startdate + trunc(random() * (enddate-startdate)) * '1 day'::interval);
				checkout_random = date(checkin_random + trunc(random() * (enddate-checkin_random)) * '1 day'::interval);
				check_overlaps = COUNT(1) > 0 FROM find_roombookings_of_hotel(idhotel) WHERE "roomid" = room_id AND (checkin_random,checkout_random) OVERLAPS (checkin,checkout);
				IF(check_overlaps = 'false') THEN 
					EXIT;
				END IF;
			END LOOP;
			
			--Select a person from the same country to be responsible and not an employee of this hotel
			LOOP
				room_responsible_id = "idClient" FROM client INNER JOIN "person" ON "person"."idPerson" = "client"."idClient"
				WHERE "country" = country_of_client ORDER BY RANDOM() LIMIT 1 ;
				check_not_employee = COUNT(1) > 0 FROM gethotelemployees(idhotel) WHERE empid = rand_client_id;
				IF (check_not_employee = 'false') THEN 
					EXIT;
				END IF;
			END LOOP;
			
			INSERT INTO "roombooking" VALUES(hbookingid,room_id,room_responsible_id,checkin_random,checkout_random, (SELECT * FROM find_rate_of_room(idhotel,room_id)));
		END LOOP;

	END LOOP;

END;
$$
LANGUAGE "plpgsql";




--Test Query
--Uncomment and select the query below to test the function after it has been created

--select generate_bookings_2_2(15,'2027-12-01','2027-12-31',10);






