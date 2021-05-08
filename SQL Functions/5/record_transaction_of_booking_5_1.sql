CREATE TRIGGER record_transaction_of_booking_5_1
    AFTER UPDATE OF payed
    ON public.hotelbooking
    FOR EACH ROW
    WHEN (new.payed)
    EXECUTE FUNCTION public.record_transaction_5_1();



CREATE FUNCTION public.record_transaction_5_1()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE 
	amount double precision;
BEGIN

	amount = sum(rate*(checkout-checkin)) FROM "roombooking" WHERE "hotelbookingID" = NEW."idhotelbooking";
	IF(amount is null) THEN
		amount = 0;
	END IF;
	
	INSERT INTO "transaction" VALUES ('booking',CAST(nextval('idtransaction') as integer),amount, NEW.idhotelbooking,(SELECT CURRENT_DATE));
			
	RETURN NEW;
END;
$BODY$;

ALTER FUNCTION public.record_transaction_5_1()
    OWNER TO postgres;
