-- Question 1: Insert
INSERT INTO cd.facilities (
    facid, name, membercost, guestcost, initialoutlay, monthlymaintenance
) VALUES (
    9, 'Spa', 20, 30, 10000, 800);

-- Question 2: Insert calculated data into a table
INSERT INTO cd.facilities (
    facid, name, membercost, guestcost, initialoutlay, monthlymaintenance
) VALUES (
    (SELECT MAX(facid) FROM cd.facilities)+1, 'Spa', 20, 30, 100000, 800);

-- Question 3: Update some existing data
UPDATE cd.facilities
SET initialoutlay = 10000
WHERE name = 'Tennis Court 2';

-- Question 4: Update a row based on the contents of another row
UPDATE cd.facilities
SET
    membercost = (
        SELECT membercost
        FROM cd.facilities
        WHERE name = 'Tennis Court 1'
    ) * 1.1,
    guestcost = (
        SELECT guestcost
        FROM cd.facilities
        WHERE name = 'Tennis Court 1'
    ) * 1.1
WHERE name = 'Tennis Court 2';

-- Question 5: Delete all bookings
DELETE FROM cd.bookings;

-- Question 6: Delete a member from the cd.members table
DELETE FROM cd.members WHERE memid = 37;

-- Question 7: Control which rows are retrieved - part 2
SELECT facid, name, membercost, monthlymaintenance
FROM cd.facilities
WHERE membercost > 0 AND (membercost < monthlymaintenance / 50);

-- Question 8: Basic string searches
SELECT * FROM cd.facilities
WHERE name LIKE '%Tennis%';

-- Question 9: Matching against multiple possible values
SELECT * FROM cd.facilities
WHERE facid IN (1, 5);

-- Question 10: Working with dates
SELECT memid, surname, firstname, joindate
FROM cd.members
WHERE joindate > '2012-09-01';

-- Question 11: Combining results from multiple queries
SELECT surname FROM cd.members
UNION
SELECT name FROM cd.facilities;

-- Question 12: Retrieve the start times of members' bookings
SELECT book.starttime
FROM cd.bookings book INNER JOIN cd.members mem ON mem.memid = book.memid
WHERE firstname = 'David' AND surname = 'Farrell';

-- Question 13: Work out the start times of bookings for tennis courts
SELECT
  starttime, name
FROM
  cd.bookings
  JOIN cd.facilities ON cd.bookings.facid = cd.facilities.facid
WHERE
  cd.facilities.name LIKE '%Tennis Court%'
  AND starttime >= '2012-09-21'
  AND starttime < '2012-09-22'
ORDER BY
  starttime ASC;

-- Question 14: Produce a list of all members, along with their recommender
SELECT
  mem.firstname as memfname,
  mem.surname as memsname,
  rec.firstname as recfname,
  rec.surname as recsname
FROM
  cd.members mem
  LEFT JOIN cd.members rec ON rec.memid = mem.recommendedby
ORDER BY
  memsname,
  memfname;

-- Question 15: Produce a list of all members who have recommended another member
SELECT DISTINCT
  rec.firstname as firstname,
  rec.surname as surname
FROM
  cd.members mem
  JOIN cd.members rec ON rec.memid = mem.recommendedby
ORDER BY
  surname,
  firstname;

-- Question 16: Produce a list of all members, along with their recommender, using no joins.
SELECT DISTINCT
  mem.firstname || ' ' || mem.surname AS member,
  (
    SELECT
      rec.firstname || ' ' || rec.surname AS recommender
    FROM
      cd.members rec
    WHERE
      rec.memid = mem.recommendedby
  )
FROM
  cd.members mem
ORDER BY
  member;

-- QUESTION 17: Count the number of recommendations each member makes.
SELECT
  recommendedby,
  COUNT(*)
FROM
  cd.members
WHERE
  recommendedby IS NOT NULL
GROUP BY
  recommendedby
ORDER BY
  recommendedby;

-- Question 18: List the total slots booked per facility
SELECT
  facid AS "Facility ID",
  SUM(slots) AS "Total Slots"
FROM
  cd.bookings
GROUP BY
  facid
ORDER BY
  facid;

-- Question 19: List the total slots booked per facility in a given month
SELECT
  facid AS "Facility ID",
  SUM(slots) AS "Total Slots"
FROM
  cd.bookings
WHERE
  starttime >= '2012-09-01'
  AND starttime < '2012-10-01'
GROUP BY
  facid
ORDER BY
  SUM(slots);

-- Question 20: List the total slots booked per facility per month
SELECT
  facid AS "Facility ID",
  EXTRACT(month FROM starttime) AS month,
  SUM(slots) AS "Total Slots"
FROM
  cd.bookings
WHERE
  EXTRACT(year FROM starttime) = 2012
GROUP BY
  facid, month
ORDER BY
  facid, month;

-- Question 21: Find the count of members who have made at least one booking
SELECT
  COUNT(DISTINCT memid)
FROM
  cd.bookings;

-- Question 22: List each member's first booking after September 1st 2012
SELECT
  surname,
  firstname,
  cd.members.memid,
  MIN(starttime)
FROM
  cd.members JOIN cd.bookings ON cd.bookings.memid = cd.members.memid
WHERE
  starttime >= '2012-09-01'
GROUP BY
  surname,
  firstname,
  cd.members.memid
ORDER BY
  cd.members.memid;

-- Question 23: Produce a list of member names, with each row containing the total member count
SELECT
  COUNT(*) OVER(),
  firstname,
  surname
FROM
  cd.members
ORDER BY
  joindate;

-- Question 24: Produce a numbered list of members
SELECT
  COUNT(*) OVER(ORDER BY joindate),
  firstname,
  surname
FROM
  cd.members;

-- Question 25: Output the facility id that has the highest number of slots booked, again
SELECT
  facid,
  total
FROM (
  SELECT
    facid,
    SUM(slots) AS total,
    RANK() over (
	  ORDER BY SUM(slots) DESC
	) rank
  FROM
    cd.bookings
  GROUP BY
    facid
  ) AS ranked
WHERE
  rank = 1

-- Question 26: Format the names of members
SELECT
  surname || ', ' || firstname AS name
FROM
  cd.members;

-- Question 27: Find telephone numbers with parentheses
SELECT
  memid, telephone
FROM
  cd.members
WHERE
  telephone ~ '^\(\d{3}\) \d{3}-\d{4}$';

-- Question 28: Count the number of members whose surname starts with each letter of the alphabet
SELECT
  SUBSTR(mem.surname, 1, 1) as letter,
  COUNT(*) AS count
FROM
  cd.members mem
GROUP BY
  letter
ORDER BY
  letter;
