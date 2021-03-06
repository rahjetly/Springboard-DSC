/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/


The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

/*Columns I want: Facility Name. No joins needed. Filter where cost is not 0.*/
SELECT *
FROM `Facilities`
WHERE membercost !=0
LIMIT 0 , 30

/* Q2: How many facilities do not charge a fee to members? */

/*Count of non-charging facilities. Select a count from facilities and filter where cost is 0.*/
SELECT COUNT( * )
FROM `Facilities`
WHERE membercost !=0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

/*Columns needed: facid, facility name, member cost, monthly maintenance, and A column for 20% of the maintenance cost. */
SELECT facid,
	name,
	membercost,
	monthlymaintenance,
	.2 * monthlymaintenance AS 20p

FROM `Facilities`

WHERE membercost != 0

HAVING membercost < 20p

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM `Facilities`
WHERE facid IN (1,5)


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

/*Columns needed: facid, facility name, maintenance cost, column created via "Select case when maintenance>100 then expensive else cheap" */

SELECT facid,
	name,
	monthlymaintenance,

CASE WHEN monthlymaintenance > 100 THEN 'Expensive'

ELSE 'Cheap' END AS E_or_C

FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT *
FROM Members
WHERE joindate=(SELECT max(joindate) FROM Members)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

/*Columns: name of court, full name of member (select concat as). Join facilities and booking and member. */

SELECT Distinct i.facility, CONCAT(i.first_name, ' ', i.last_name) AS full_name
FROM (
    SELECT f.name AS facility, m.firstname AS first_name, m.surname AS last_name
    FROM Bookings b
    INNER JOIN Facilities f ON b.facid = f.facid AND f.name LIKE 'Tennis Court%'
    INNER JOIN Members m ON m.memid = b.memid
) i
ORDER BY full_name

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT 
	f.name as Facility,
	CONCAT(m.firstname, ' ', m.surname) AS full_name,
CASE WHEN b.memid = 0 
THEN f.guestcost * b.slots 
ELSE f.membercost * b.slots 
END AS Cost
FROM `Bookings` b
INNER JOIN `Members` m
	ON b.memid = m.memid
INNER JOIN `Facilities` f
	ON f.facid = b.facid
WHERE b.starttime >= '2012-09-14' AND b.starttime < '2012-09-15'
AND	((m.memid = 0 AND f.guestcost*b.slots>30)
OR ((m.memid != 0) AND f.membercost*b.slots>30))
ORDER BY Cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT facility, full_name, Cost
FROM (
    SELECT f.name AS facility, CONCAT(m.firstname,' ', m.surname) AS full_name,
CASE WHEN m.memid =0
    THEN b.slots*f.guestcost
    ELSE b.slots*f.membercost 
    END AS Cost
FROM Bookings b
INNER JOIN Facilities f
      ON b.facid = f.facid
INNER JOIN Members m 
      ON m.memid = b.memid
WHERE b.starttime >= '2012-09-14' AND b.starttime < '2012-09-15'
) i
WHERE cost > 30
ORDER BY cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT *
FROM
(SELECT inside.Name,
	SUM(inside.cost) as Revenue
FROM (
SELECT Facilities.name as Name,
CASE WHEN Bookings.memid = 0 
	THEN Facilities.guestcost * Bookings.slots
	ELSE Facilities.membercost * Bookings.slots
END AS Cost
FROM Bookings
INNER JOIN Facilities on Bookings.facid = Facilities.facid
INNER JOIN Members on Bookings.memid = Members.memid
) inside
GROUP By inside.Name
ORDER BY Revenue DESC) inside2
WHERE Revenue < 1000

