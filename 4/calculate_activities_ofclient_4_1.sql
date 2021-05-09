CREATE FUNCTION calculate_activities_ofclient_4_1(hotelid integer) RETURNS TABLE("Client ID" integer, "Number of participation" bigint)
AS
$$

BEGIN

	RETURN QUERY
	SELECT "Client IDs", COUNT(CASE WHEN "role" = 'participant' THEN 1 ELSE NULL END)  as "Participations" FROM
	(SELECT * FROM "participates" RIGHT JOIN (SELECT * FROM gethotelclients(hotelid)) as hotelclients
	ON hotelclients."Client IDs" = "participates"."idperson") as tbl
	GROUP BY "Client IDs","role"
	ORDER BY "Client IDs";
	
END;

$$
LANGUAGE "plpgsql";


--Test Query
--Uncomment and select the query below to test the function after it has been created
--SELECT * FROM calculate_activities_ofclient_4_1(15)

--function checked