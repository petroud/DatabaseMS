CREATE FUNCTION delete_client_2_1(docClient varchar, lastname varchar, cardnumber varchar) 
RETURNS table("Operation Result" text) 
AS 
$$

DECLARE idtodelete integer;

BEGIN
	
	SELECT "idPerson" INTO idtodelete FROM "person"
    WHERE "idPerson" = (SELECT "idClient" FROM "client" WHERE "documentclient" = docClient);
	
	DELETE FROM "creditcard" WHERE "clientID" = idtodelete;
	DELETE FROM "client" WHERE "idClient" = idtodelete;
	DELETE FROM "person" WHERE "idPerson" = idtodelete;
											 
RETURN QUERY
	SELECT 'Success, Client Deleted';
	
END;
$$
LANGUAGE "plpgsql";



--Test Query
--Uncomment and select the query below to test the function after it has been created
--SELECT * FROM delete_client_2_1('ABCDEFGH','PAPADOPOULOS','5332 5533 5444 4444')

--function checked
