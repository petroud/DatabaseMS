CREATE FUNCTION public.check_validity_of_canceldate_change_5_2()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
	IF (SELECT find_hotel_manager((SELECT find_hotel_ofbooking(OLD."idhotelbooking"))) = (SELECT find_booking_whomanages(OLD."idhotelbooking"))) THEN
		RETURN NEW;
	ELSE
		RAISE NOTICE 'The booking is not managed by the hotel manager ! Cancellation date cannot be changed !';
		RETURN OLD;			
	END IF;
END;
$BODY$;

ALTER FUNCTION public.check_validity_of_canceldate_change_5_2()
    OWNER TO postgres;



CREATE TRIGGER validate_booking_date_changes_5_2
    BEFORE UPDATE OF cancellationdate
    ON public.hotelbooking
    FOR EACH ROW
    EXECUTE FUNCTION public.check_validity_of_canceldate_change_5_2();




CREATE FUNCTION public.check_validity_of_roombooking_changes_5_2()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
	IF(TG_OP = 'UPDATE') THEN
	--On update or delete we check what changes are allowed to be made
		IF((SELECT CURRENT_DATE)<(SELECT find_cancel_date_of_booking(OLD."hotelbookingID"))) THEN
		--If the booking cancellation date is not due
			RETURN NEW;
		ELSE
		--If the booking cancellation date is due 
			IF (NEW."checkin" <> OLD."checkin" OR NEW."checkout" <> OLD."checkout") THEN
				IF((SELECT OLD."checkout"-OLD."checkin") <= (SELECT NEW."checkout"-NEW."checkin")) THEN
					RETURN NEW;
				ELSE
					RAISE NOTICE 'Because the cancellation date is due! The booking days can only be extended';
					RETURN OLD;	
				END IF;
			ELSE
				RETURN NEW;
			END IF;		   		   	   
		END IF;		   
	ELSIF (TG_OP = 'INSERT') THEN
	--We check if the insertion of new rooms is legal
		IF(NEW.checkin > NEW.checkout OR NEW.checkin < (SELECT CURRENT_DATE)) THEN
		   RAISE EXCEPTION 'Illegal dates on insertion of new room booking! Please revise your input!';
		ELSE
		   RETURN NEW;
		END IF;
		   
	ELSIF (TG_OP = 'DELETE') THEN
		IF((SELECT CURRENT_DATE)<(SELECT find_cancel_date_of_booking(OLD."hotelbookingID"))) THEN
		--If the booking cancellation date is not due
			RETURN OLD;
		ELSE
			RAISE EXCEPTION 'Because the cancellation date is due! Room booking cannot be deleted';
		END IF;		      		   
	END IF;
END;
$BODY$;

ALTER FUNCTION public.check_validity_of_roombooking_changes_5_2()
    OWNER TO postgres;


CREATE TRIGGER validate_booking_date_changes_5_2
BEFORE INSERT OR DELETE OR UPDATE 
ON public.roombooking
FOR EACH ROW
EXECUTE FUNCTION public.check_validity_of_roombooking_changes_5_2();