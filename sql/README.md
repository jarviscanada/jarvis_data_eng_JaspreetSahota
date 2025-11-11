# Introduction
This project focuses on developing a strong foundation in 
Relational Database Management Systems (RDBMS) and working 
with SQL queries. It emphasizes practical, hands-on learning 
through the setup and management of a PostgreSQL environment, 
allowing developers to gain experience with real database 
workflows and query execution.

A PostgreSQL container was provisioned using Docker and Bash, 
where the sample database was constructed and initialized. The 
psql command-line interface was then used to connect to the 
database and insert sample data from the `clubdata.sql` file, 
simulating a realistic data setup process.

The project focuses on a variety of SQL operations that cover 
Data Definition (DDL), Data Manipulation (DML), and Data Query 
Language (DQL) commands. This strengthened our understanding of 
relational data, improve query-writing skills, and manage databases 
in a professional development environment.

# SQL Queries
### Table Setup (DDL)
```sql
CREATE TABLE IF NOT EXISTS cd.members (
    memid integer PRIMARY KEY,
    surname varchar(200) NOT NULL,
    firstname varchar(200) NOT NULL,
    address varchar(300) NOT NULL,
    zipcode integer NOT NULL,
    telephone varchar(20) NOT NULL,
    recommendedby integer REFERENCES cd.members(memid),
    joindate timestamp NOT NULL
);

CREATE TABLE IF NOT EXISTS cd.facilities (
    facid integer PRIMARY KEY,
    name varchar(100) NOT NULL,
    membercost numeric NOT NULL,
    guestcost numeric NOT NULL,
    initialoutlay numeric NOT NULL,
    monthlymaintenance numeric NOT NULL
);

CREATE TABLE IF NOT EXISTS cd.bookings (
    bookid integer PRIMARY KEY,
    facid integer NOT NULL REFERENCES cd.facilities(facid),
    memid integer NOT NULL REFERENCES cd.members(memid),
    starttime timestamp NOT NULL,
    slots integer NOT NULL
);
```

### Practice SQL Queries
#### Modifying Data
##### Question 1: Insert some data into a table
The club is adding a new facility - a spa. We need to add it into the 
facilities table. Use the following values:
- facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.

Solution:
```sql
INSERT INTO cd.facilities (
    facid, name, membercost, guestcost, initialoutlay, monthlymaintenance
) VALUES (
    9, 'Spa', 20, 30, 10000, 800);
```

##### Question 2: Insert calculated data into a table
Let's try adding the spa to the facilities table again. This time, though, 
we want to automatically generate the value for the next facid, rather 
than specifying it as a constant. Use the following values for everything else:
- Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.

Solution:
```sql
INSERT INTO cd.facilities (
    facid, name, membercost, guestcost, initialoutlay, monthlymaintenance
) VALUES (
    (SELECT MAX(facid) FROM cd.facilities)+1, 'Spa', 20, 30, 100000, 800);
```

##### Question 3: Update some existing data
We made a mistake when entering the data for the second tennis court. 
The initial outlay was 10000 rather than 8000: you need to alter the 
data to fix the error.

Solution:
```sql
UPDATE cd.facilities
    SET initialoutlay = 10000
    WHERE name = 'Tennis Court 2';
```

##### Question 4: Update a row based on the contents of another row
We want to alter the price of the second tennis court so that it costs 
10% more than the first one. Try to do this without using constant values 
for the prices, so that we can reuse the statement if we want to.

Solution:
```sql
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
```

##### Question 5: Delete all bookings
As part of a clearout of our database, we want to delete all bookings 
from the cd.bookings table. How can we accomplish that?

Solution:
```sql
DELETE FROM cd.bookings;
```

##### Question 6: Delete a member from the cd.members table
We want to remove member 37, who has never made a booking, from our database. 
How can we achieve that?

Solution:
```sql
DELETE FROM cd.members WHERE memid = 37;
```

#### Basics
##### Question 7: Control which rows are retrieved - part 2
How can you produce a list of facilities that charge a fee to 
members, and that fee is less than 1/50th of the monthly maintenance 
cost? Return the facid, facility name, member cost, and monthly 
maintenance of the facilities in question.

Solution:
```sql
SELECT facid, name, membercost, monthlymaintenance
FROM cd.facilities
WHERE membercost > 0 AND (membercost < monthlymaintenance / 50);
```

##### Question 8: Basic string searches
How can you produce a list of all facilities with the word 
'Tennis' in their name?

Solution:
```sql
SELECT * FROM cd.facilities
WHERE name LIKE '%Tennis%';
```

##### Question 9: Matching against multiple possible values
How can you retrieve the details of facilities with ID 1 and 5? 
Try to do it without using the OR operator.

Solution:
```sql
SELECT * FROM cd.facilities 
WHERE facid IN (1, 5);
```

##### Question 10: Working with dates
How can you produce a list of members who joined after the start of 
September 2012? Return the memid, surname, firstname, and joindate of 
the members in question.

Solution:
```sql
SELECT memid, surname, firstname, joindate
FROM cd.members
WHERE joindate > '2012-09-01';
```

##### Question 11: Combining results from multiple queries
You, for some reason, want a combined list of all surnames and all facility names.

Solution:
```sql
SELECT surname FROM cd.members
UNION
SELECT name FROM cd.facilities;
```

#### Join
##### Question 12: Retrieve the start times of members' bookings
How can you produce a list of the start times for bookings by members named 'David Farrell'?

Solution:
```sql
SELECT book.starttime
FROM cd.bookings book INNER JOIN cd.members mem ON mem.memid = book.memid
WHERE firstname = 'David' AND surname = 'Farrell';
```

##### Question 13: Work out the start times of bookings for tennis courts
How can you produce a list of the start times for bookings for tennis courts, for the 
date '2012-09-21'? Return a list of start time and facility name pairings, ordered by the time.

Solution:
```sql 
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
```

##### Question 14: Produce a list of all members, along with their recommender
How can you output a list of all members, including the individual who recommended 
them (if any)? Ensure that results are ordered by (surname, firstname).

Solution:
```sql
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
```

##### Question 15: Produce a list of all members who have recommended another member
How can you output a list of all members who have recommended another member? Ensure 
that there are no duplicates in the list, and that results are ordered by (surname, firstname).

Solution:
```sql
SELECT DISTINCT
  rec.firstname as firstname, 
  rec.surname as surname 
FROM 
  cd.members mem 
  JOIN cd.members rec ON rec.memid = mem.recommendedby 
ORDER BY 
  surname, 
  firstname;
```

##### Question 16: Produce a list of all members, along with their recommender, using no joins.
How can you output a list of all members, including the individual who recommended 
them (if any), without using any joins? Ensure that there are no duplicates in the 
list, and that each firstname + surname pairing is formatted as a column and ordered.

Solution:
```sql
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
```

#### Aggregation
##### Question 17: Count the number of recommendations each member makes.
Produce a count of the number of recommendations each member has made. Order by member ID.

Solution:
```sql
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
```

##### Question 18: List the total slots booked per facility
Produce a list of the total number of slots booked per facility. 
For now, just produce an output table consisting of facility id 
and slots, sorted by facility id.

Solution:
```sql
SELECT 
  facid AS "Facility ID", 
  SUM(slots) AS "Total Slots" 
FROM 
  cd.bookings 
GROUP BY 
  facid 
ORDER BY 
  facid;
```

##### Question 19: List the total slots booked per facility in a given month
Produce a list of the total number of slots booked per facility in the 
month of September 2012. Produce an output table consisting of facility 
id and slots, sorted by the number of slots.

Solution:
```sql
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
```

##### Question 20: List the total slots booked per facility per month
Produce a list of the total number of slots booked per facility per month 
in the year of 2012. Produce an output table consisting of facility id and 
slots, sorted by the id and month.

Solution:
```sql
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
```

##### Question 21: Find the count of members who have made at least one booking
Find the total number of members (including guests) who have made at least one booking.

```sql
SELECT 
  COUNT(DISTINCT memid) 
FROM 
  cd.bookings;
```

##### Question 22: List each member's first booking after September 1st 2012
Produce a list of each member name, id, and their first booking after 
September 1st 2012. Order by member ID.

Solution:
```sql
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
```

##### Question 23: Produce a list of member names, with each row containing the total member count
Produce a list of member names, with each row containing the total member count. Order by join date, 
and include guest members.

Solution:
```sql
SELECT 
  COUNT(*) OVER(), 
  firstname, 
  surname 
FROM 
  cd.members 
ORDER BY
  joindate;
```

##### Question 24: Produce a numbered list of members
Produce a monotonically increasing numbered list of members (including guests), 
ordered by their date of joining. Remember that member IDs are not guaranteed 
to be sequential.

Solution:
```sql
SELECT 
  COUNT(*) OVER(ORDER BY joindate), 
  firstname, 
  surname
FROM 
  cd.members;
```

##### Question 25: Output the facility id that has the highest number of slots booked, again
Output the facility id that has the highest number of slots booked. Ensure that 
in the event of a tie, all tieing results get output.

Solution:
```sql
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
```

#### String
##### Question 26: Format the names of members
Output the names of all members, formatted as 'Surname, Firstname'

Solution:
```sql
SELECT
  surname || ', ' || firstname AS name
FROM
  cd.members;
```

##### Question 27: Find telephone numbers with parentheses
You've noticed that the club's member table has telephone numbers 
with very inconsistent formatting. You'd like to find all the 
telephone numbers that contain parentheses, returning the member 
ID and telephone number sorted by member ID.

Solution:
```sql
SELECT 
  memid, telephone
FROM 
  cd.members
WHERE 
  telephone ~ '^\(\d{3}\) \d{3}-\d{4}$';
```

##### Question 28: Count the number of members whose surname starts with each letter of the alphabet
You'd like to produce a count of how many members you have whose 
surname starts with each letter of the alphabet. Sort by the letter, 
and don't worry about printing out a letter if the count is 0.

Solution:
```sql
SELECT
  SUBSTR(mem.surname, 1, 1) as letter, 
  COUNT(*) AS count 
FROM 
  cd.members mem 
GROUP BY 
  letter
ORDER BY
  letter;
```