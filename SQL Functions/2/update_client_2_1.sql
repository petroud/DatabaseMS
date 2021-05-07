CREATE FUNCTION update_client_2_1(docClient varchar, fnamee varchar, lnamee varchar, sexx character, dateofbirthh date, addresss varchar, cityy varchar, countryy varchar, cardtypee varchar, cardnumberr varchar, holderr varchar, expirationn date)
RETURNS table("Operation Result" text) 
AS 
$$
BEGIN

UPDATE "person"
SET "fname" = fnamee, "lname" = lnamee, "sex" = sexx, "dateofbirth" = dateofbirthh, "address" = addresss, "city" = cityy, "country" = countryy
WHERE "idPerson" = (SELECT "idClient" FROM "client" WHERE "documentclient" = docClient);

UPDATE "creditcard" 
SET "cardtype" = cardtypee, "number" = cardnumberr, "expiration" = expirationn, "holder" = holderr
WHERE "clientID" = (SELECT "idClient" FROM "client" WHERE "documentclient" = docClient);
	
RETURN QUERY
	SELECT CONCAT('Success, Client ', (SELECT "idClient" FROM "client" WHERE "documentclient" = docClient),' updated');
	
END;
$$
LANGUAGE "plpgsql";

--Test Query
--Uncomment and select the query below to test the function after it has been created

--SELECT * FROM update_client_2_1('1905133426','ANTONIS','PAPADOPOULOS','M','1967-04-23','STADIOU STR','ATHENS','GREECE','VISA','5332 5533 5444 4444','A PAPADOPOULOS','2023-09-04')
