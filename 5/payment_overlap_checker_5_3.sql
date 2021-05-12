CREATE FUNCTION public.overlap_check_5_3()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	numOfbookings integer;
	dateOfOtherBooking date;
	dateOfUpdatedBooking date;
BEGIN

numOfbookings =  COUNT(*) FROM "roombooking" where "roomID" = OLD."roomID";

IF(numOfbookings>1) THEN
	
	FOR i in 1..numOfBookings LOOP
		
		dateOfOtherBooking = "checkin" FROM "roombooking" where "roomID" = OLD."roomID" AND NOT "hotelbookingID"=NEW."hotelbookingID" ORDER BY "hotelbookingID" LIMIT 1 OFFSET i;
		dateOfUpdatedBooking = "checkout" FROM "roombooking" where "roomID" = NEW."roomID" AND "hotelbookingID"=NEW."hotelbookingID";
		
		IF(dateOfOtherBooking < dateOfUpdatedBooking) THEN
			RAISE NOTICE 'The room is not available for this checkout date! Next available date for checkout is on %', dateOfOtherBooking-1;
			RETURN OLD;	
		ELSE
			RETURN NEW;
		END IF;
		
	END LOOP;
	
ELSE
	RETURN NEW;
END IF;

END;
$BODY$;

ALTER FUNCTION public.overlap_check_5_3()
    OWNER TO postgres;


CREATE TRIGGER overlap_checker_5_3
    BEFORE UPDATE OF checkout
    ON public.roombooking
    FOR EACH ROW
    EXECUTE FUNCTION public.overlap_check_5_3();








CREATE FUNCTION public.update_payment_changes_5_3()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	oldtotal real;
	newtotal real;
	amount real;
BEGIN

		IF((SELECT payed FROM "hotelbooking" WHERE "idhotelbooking" = NEW."hotelbookingID")) THEN
		
			IF((SELECT CURRENT_DATE)<(SELECT find_cancel_date_of_booking(NEW."hotelbookingID"))) THEN
			   
				IF(TG_OP = 'UPDATE' OR TG_OP = 'INSERT') THEN
			   		IF(TG_OP = 'INSERT')THEN
						oldtotal = SUM("transaction".amount) FROM "transaction" WHERE "idHotelBooking" = NEW."hotelbookingID";
					ELSE
						oldtotal = SUM("transaction".amount) FROM "transaction" WHERE "idHotelBooking" = OLD."hotelbookingID";
					END IF;
					newtotal = SUM(rate*(checkout-checkin)) FROM "roombooking" WHERE "hotelbookingID" = NEW."hotelbookingID";
					RAISE NOTICE 'Old total: %', oldtotal;
					RAISE NOTICE 'New total: %', newtotal;
					amount = newtotal-oldtotal;

					INSERT INTO "transaction" VALUES ('update',nextval('idtransaction'),CAST(amount AS real),NEW."hotelbookingID",(SELECT CURRENT_DATE));
			   		RETURN NEW;
			   
			  	ELSIF(TG_OP = 'DELETE') THEN
			   		
					oldtotal = rate*(checkout-checkin) FROM "roombooking" WHERE "hotelbookingID"=OLD."hotelbookingID" AND "roomID" = OLD."roomID";
			   
			   		INSERT INTO "transaction" VALUES ('cancellation',nextval('idtransaction'),CAST(amount AS real),OLD."hotelbookingID",(SELECT CURRENT_DATE));
			   		RETURN OLD;
			   
			   	END IF;
			   
			ELSE
			   
			   RAISE NOTICE 'The booking has been payed but the cancellation date is due, no changes or refunds allowed!';
			   RETURN OLD;
			   
			END IF;
			RETURN OLD;
		END IF;
		
		RETURN OLD;
END;
$BODY$;

ALTER FUNCTION public.update_payment_changes_5_3()
    OWNER TO postgres;


CREATE TRIGGER updater_payment_changes_5_3
    AFTER DELETE OR UPDATE 
    ON public.roombooking
    FOR EACH ROW
    EXECUTE FUNCTION public.update_payment_changes_5_3();




    






CREATE FUNCTION public.update_totalamount_for_booking_5_3()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN

	IF(TG_OP = 'DELETE') THEN
		UPDATE "hotelbooking" SET "totalamount"=
		(SELECT CAST(SUM(rate * (checkout-checkin)) as real) FROM "roombooking" WHERE "hotelbookingID" = OLD."hotelbookingID")
		WHERE "idhotelbooking" = OLD."hotelbookingID";		
		RETURN OLD;
	ELSE
		UPDATE "hotelbooking" SET "totalamount"=
		(SELECT CAST(SUM(rate * (checkout-checkin)) as real) FROM "roombooking" WHERE "hotelbookingID" = NEW."hotelbookingID")
		WHERE "idhotelbooking" = NEW."hotelbookingID";		
		RETURN NEW;	
	END IF;
	
END;
$BODY$;

ALTER FUNCTION public.update_totalamount_for_booking_5_3()
    OWNER TO postgres;


CREATE TRIGGER totalamount_updater_5_3
    AFTER INSERT OR DELETE OR UPDATE 
    ON public.roombooking
    FOR EACH ROW
    EXECUTE FUNCTION public.update_totalamount_for_booking_5_3();