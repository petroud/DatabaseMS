CREATE FUNCTION find_hotel_empty_activities_3_5(idhot integer) RETURNS TABLE("Activity Type" activity_type, "Weekday" weekday_type, "Start Time" timestamp without time zone, "End Time" timestamp without time zone, "Hotel ID" integer)
AS
$$
BEGIN
	RETURN QUERY
	SELECT "act_type", "activity"."weekday", "activity"."starttime", "activity"."endtime", "activity"."idhotel"  FROM "activity" 
	INNER JOIN  (SELECT "hotelActs"."weekday","hotelActs"."starttime","hotelActs"."endtime","hotelActs"."idhotel" FROM "participates" 
				INNER JOIN (SELECT "activity"."weekday","activity"."starttime","activity"."endtime", "activity"."idhotel" FROM "activity" WHERE "activity"."idhotel" = idhot) as "hotelActs"
				ON "participates"."weekday" = "hotelActs"."weekday" AND "participates"."starttime" = "hotelActs"."starttime" AND "participates"."endtime" = "hotelActs"."endtime" AND "participates"."idhotel" = "hotelActs"."idhotel"
				GROUP BY "hotelActs"."weekday","hotelActs"."starttime","hotelActs"."endtime","hotelActs"."idhotel"
				HAVING COUNT(*) = 1) as empty_acts
	ON "activity"."weekday" = empty_acts."weekday" AND "activity"."starttime" = empty_acts."starttime"  AND "activity"."endtime" = empty_acts."endtime" AND "activity"."idhotel" = empty_acts."idhotel";
	
END;
$$
LANGUAGE "plpgsql";

--Test Query
--Uncomment and select the query below to test the function after it has been created

--SELECT * FROM find_hotel_empty_activities_3_5(12)

--function checked