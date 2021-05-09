CREATE FUNCTION edit_client_2_1(actionArg varchar, docClient varchar, fnamee varchar, lnamee varchar, sexx character, dateofbirthh date, addresss varchar, cityy varchar, countryy varchar, cardtypee varchar, cardnumberr varchar, holderr varchar, expirationn date) 
RETURNS TABLE("Action Result" text)
AS
$$
BEGIN

	CASE
    WHEN actionArg='insert' THEN 
		RETURN QUERY SELECT * FROM insert_client_2_1(docClient , fnamee , lnamee , sexx , dateofbirthh, addresss , cityy, countryy, cardtypee, cardnumberr, holderr,expirationn);
    WHEN actionArg='update' THEN 
		RETURN QUERY SELECT * FROM update_client_2_1(docClient , fnamee , lnamee , sexx , dateofbirthh, addresss , cityy, countryy, cardtypee, cardnumberr, holderr,expirationn);
    WHEN actionArg='delete' THEN
		RETURN QUERY SELECT * FROM delete_client_2_1(docClient , lnamee , cardnumberr);
    ELSE 
		RETURN QUERY SELECT 'This action is not an option! Please choose insert/update/delete';
	END CASE;
END;

$$
LANGUAGE "plpgsql"