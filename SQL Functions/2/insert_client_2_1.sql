CREATE FUNCTION insert_client_2_1(docClient varchar, fname varchar, lname varchar, sex character, dateofbirth date, address varchar, city varchar, country varchar, cardtype varchar, cardnumber varchar, holder varchar, expiration date) 
RETURNS table("Operation Result" text) 
AS 
$$
BEGIN

INSERT INTO "person" ("idPerson","fname","lname","sex","dateofbirth","address","city","country") VALUES 
	(nextval('idperson'),fname,lname,sex,dateofbirth,address,city,country);

INSERT INTO "client" ("idClient","documentclient") VALUES 
	((SELECT "idPerson" FROM "person" WHERE "idPerson"=currval('idperson')), docClient);

INSERT INTO "creditcard" ("cardtype","number","expiration","holder","clientID") VALUES
    (cardtype,cardnumber,expiration, holder, (SELECT "idClient" FROM "client" WHERE "idClient" = currval('idperson')));

RETURN QUERY
	SELECT 'Success, New Client Added';
	
END;
$$
LANGUAGE "plpgsql";

--Test Query
--Uncomment and select the query below to test the function after it has been created

--select * from insert_client_2_1('ABCDEFGH','ANTONIS','PAPADOPOULOS','M','1967-04-23','STADIOU STR','ATHENS','GREECE','VISA','5332 5533 5444 4444','A PAPADOPOULOS','2023-09-04')



