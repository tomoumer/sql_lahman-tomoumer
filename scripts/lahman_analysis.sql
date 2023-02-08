-- 1. Find all players in the database who played at Vanderbilt University. Create a list showing each player's first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
-- a: David Price with $81 million USD!

/* using code below I waws able to find out Vanderbilt University is called 'vandy'
INNER JOIN schools
USING(schoolid)
WHERE schoolname='Vanderbilt University';
*/

-- WITH vandy_players AS (SELECT DISTINCT
-- 	playerid,
-- 	namefirst,
-- 	namelast
-- FROM people
-- INNER JOIN collegeplaying
-- USING(playerid)
-- WHERE schoolid='vandy')
-- SELECT
-- 	--playerid,
-- 	namefirst,
-- 	namelast,
-- 	SUM(salary)::NUMERIC::MONEY AS total_salary
-- FROM vandy_players
-- LEFT JOIN salaries
-- USING(playerid)
-- GROUP BY playerid, namefirst, namelast
-- ORDER BY total_salary DESC NULLS LAST;



