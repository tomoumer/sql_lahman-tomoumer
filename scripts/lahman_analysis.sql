-- 1. Find all players in the database who played at Vanderbilt University. Create a list showing each player's first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
-- a: David Price with $81 million USD!

/* using code below I found out Vanderbilt University is called 'vandy'
INNER JOIN schools
USING(schoolid)
WHERE schoolname='Vanderbilt University';
*/

-- WITH vandy_players AS (
-- SELECT DISTINCT
-- 	playerid,
-- 	namefirst,
-- 	namelast
-- FROM people
-- INNER JOIN collegeplaying
-- USING(playerid)
-- WHERE schoolid='vandy'
-- )
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

-- 2. Using the fielding table, group players into three groups based on their position (pos): label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts (po) made by each of these three groups in 2016 (yearid).
-- NOTE: put in parenthesis column names by reading the txt file online

-- SELECT
-- 	CASE
-- 		WHEN pos = 'OF' THEN 'Outfield'
-- 		WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
-- 		WHEN pos IN ('P', 'C') THEN 'Battery'
-- 		END AS position_group,
-- 	SUM(po) AS total_putout
-- FROM fielding
-- WHERE yearid = 2016
-- GROUP BY position_group;

-- 3. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends? (NOTE: see helpful links in the README)
-- a: it appears the average strikeouts has been steadily increasing over the years - almost 100 years later it essentially trippled!
-- NOTE: doing an AVG, vs SUM can be different if the teams play a different number of games - SUM in a sense does a weighted average
-- NOTE2: it also depends if we're looking at it per game, or per game PER team (with SUM we'd have to divide by 2 to get per game)

-- WITH decades AS (
-- 	SELECT generate_series(1920, 2010, 10) AS begin_decade,
-- 		generate_series(1929, 2019, 10) AS end_decade
-- )
-- SELECT
-- 	--begin_decade,
-- 	--end_decade,
-- 	begin_decade::text || 's' AS decade, 
-- 	--ROUND(AVG(SO+SOA)::NUMERIC / G), 2) AS average_strikeouts,
-- 	--ROUND(AVG(HR+HRA)::NUMERIC / G), 2) AS average_homeruns
-- 	ROUND(SUM(SO) * 1.0 / SUM(G), 2) AS average_strikeouts,
-- 	ROUND(SUM(HR) * 1.0 / SUM(G), 2) AS average_homeruns
-- FROM decades
-- LEFT JOIN teams
-- ON yearid >= begin_decade
-- AND yearid <= end_decade
-- -- ON yearid BETWEEN begin_decade AND end_decade -- alternative to above
-- GROUP BY decade
-- ORDER BY decade;

-- 4. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases. Report the players' names, number of stolen bases, number of attempts, and stolen base percentage.
-- NOTE: attempts are stolen bases (sb) + caught stealing (cs). By groupingby playerid I also ensured that the resulting join with those limits doesn't have duplicate players (when they played for multiple teams)
-- a: Chris Owings
-- NOTE2:, needed to group in batting because same player might change teams

-- WITH full_batting AS(
-- 	SELECT
-- 		playerid,
-- 		SUM(sb) AS sb,
-- 		SUM(cs) AS cs,
-- 		SUM(sb) + SUM(cs) AS attempts
-- 	FROM batting
-- 	WHERE yearid=2016
-- 	GROUP BY playerid
-- )
-- SELECT
-- 	namefirst,
-- 	namelast,
-- 	sb,
-- 	attempts,
-- 	ROUND(100.*sb/ attempts,2) AS stolen_percentage
-- FROM people
-- INNER JOIN full_batting
-- USING(playerid)
-- WHERE attempts >= 20
-- ORDER BY stolen_percentage DESC;


-- 5. From 1970 to 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion; determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 to 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
-- a: largest wins while not winning world 116, smallest wins while winning world is 63 
-- Found out that the strange year was 1981 - In 1981 major league baseball shut down for 50 days from June 12 to August 10. During that time a total of 713 games were lost. The reason behind the strike was free agent player compensation.
-- a: 12 times the team with most wins also won the world series; 23% of the time

-- SELECT MAX(W)
-- FROM teams
-- WHERE yearid BETWEEN 1970 AND 2016
-- 	AND wswin ='N';

-- SELECT
-- 	yearid,
-- 	teamid,
-- 	w
-- FROM teams
-- WHERE yearid BETWEEN 1970 AND 2016
-- 	AND wswin ='Y'
-- 	AND W = (
-- 	SELECT MIN(W) AS min_w
-- 	FROM teams
-- 	WHERE yearid BETWEEN 1970 AND 2016
-- 		AND wswin ='Y'
-- );

-- SELECT *
-- FROM teams
-- WHERE yearid BETWEEN 1970 AND 2016
-- 	AND yearid <> 1981
-- 	AND wswin ='Y';

-- WITH year_wins AS (
-- 	SELECT
-- 		yearid,
-- 		MAX(W) AS max_w
-- 	FROM teams
-- 	WHERE yearid BETWEEN 1970 AND 2016
-- 		--AND yearid <> 1981
-- 	GROUP BY yearid
-- )	
-- SELECT 
-- 	SUM(CASE WHEN wswin ='Y' THEN 1 ELSE 0 END) AS win_win,
-- 	ROUND(AVG(CASE WHEN wswin ='Y' THEN 1 ELSE 0 END),2) AS fraction_win
-- FROM teams t
-- LEFT JOIN year_wins
-- ON t.yearid = year_wins.yearid
-- 	AND t.W = year_wins.max_w
-- WHERE max_w IS NOT NULL;


-- 6. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
-- a: Jim Leyland, Davey Johnson

-- SELECT
-- 	namefirst || ' ' || namelast AS full_name,
-- 	awmg.yearid,
-- 	awmg.lgid,
-- 	teamid
-- FROM awardsmanagers AS awmg
-- INNER JOIN people
-- USING(playerid)
-- INNER JOIN managers AS m
-- ON awmg.playerid = m.playerid
-- 	AND awmg.yearid = m.yearid
-- WHERE (awmg.playerid, awmg.awardid) IN (
-- 	SELECT playerid,
-- 		awardid
-- 	FROM awardsmanagers
-- 	WHERE awardid = 'TSN Manager of the Year'
-- 		AND lgid IN ('NL','AL')
-- 	GROUP BY playerid, awardid
-- 	HAVING COUNT( DISTINCT lgid) = 2
-- );

-- 7. Which pitcher was the least efficient in 2016 in terms of salary / strikeouts? Only consider pitchers who started at least 10 games (across all teams). Note that pitchers often play for more than one team in a season, so be sure that you are counting all stats for each player.

/*
My original solution, the code below, was incorrect - for some reason some players don't have reported salaries for certain teamms that they played on! so we have to group by playerid in each table separately
SELECT 
	playerid,
	SUM(so) AS tot_strikeouts,
	SUM(salary)::numeric::money AS tot_salary,
	SUM(salary)::numeric::money / SUM(so) AS salary_strike
FROM pitching p
LEFT JOIN salaries s
USING (playerid)
WHERE p.yearid = 2016
 	AND s.yearid = 2016
GROUP BY playerid
HAVING SUM(gs) > 10
ORDER BY salary_strike DESC;
*/

-- Michael's code, avoiding double counting
-- WITH full_pitching AS (
-- 	SELECT 
-- 		playerid,
-- 		SUM(so) AS so
-- 	FROM pitching
-- 	WHERE yearid = 2016
-- 	GROUP BY playerid
-- 	HAVING SUM(gs) >= 10
-- ),
-- full_salary AS (
-- 	SELECT
-- 		playerid,
-- 		SUM(salary) AS salary
-- 	FROM salaries
-- 	WHERE yearid = 2016
-- 	GROUP BY playerid
-- )
-- SELECT 
-- 	namefirst || ' ' || namelast AS fullname,
-- 	salary::numeric::MONEY / so AS so_efficiency
-- FROM full_pitching
-- NATURAL JOIN full_salary
-- INNER JOIN people
-- USING(playerid)
-- ORDER BY so_efficiency DESC;

-- 8. Find all players who have had at least 3000 career hits. Report those players' names, total number of hits, and the year they were inducted into the hall of fame (If they were not inducted into the hall of fame, put a null in that column.) Note that a player being inducted into the hall of fame is indicated by a 'Y' in the **inducted** column of the halloffame table.

-- WITH career AS (
-- 	SELECT
-- 		playerid,
-- 		SUM(h) as career_hits
-- 	FROM batting
-- 	GROUP BY playerid
-- 	HAVING SUM(h) >= 3000
-- ),
-- hall_inducted AS (
-- 	SELECT
-- 		playerid,
-- 		yearid
-- 	FROM halloffame
-- 	WHERE inducted='Y'
-- )
-- SELECT
-- 	namefirst || ' ' || namelast AS full_name,
-- 	career_hits,
-- 	yearid AS year_inducted
-- FROM career
-- LEFT JOIN hall_inducted
-- USING(playerid)
-- INNER JOIN people
-- USING(playerid)
-- ORDER BY year_inducted;

-- 9. Find all players who had at least 1,000 hits for two different teams. Report those players' full names.

-- WITH over_1000_hits AS (
-- 	SELECT
-- 		playerid,
-- 		teamid,
-- 		SUM(h) as team_hits
-- 	FROM batting
-- 	GROUP BY playerid, teamid
-- 	HAVING SUM(h) >= 1000
-- )
-- SELECT 
-- 	namefirst || ' ' || namelast AS full_name
-- FROM over_1000_hits
-- INNER JOIN people
-- USING (playerid)
-- GROUP BY playerid , namefirst, namelast
-- HAVING COUNT(*) > 1;

--10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.
-- a: run the query, 9 players

-- at least one hr in 2016, 542 players
-- WITH hr_in_2016 AS (
-- 	SELECT
-- 		playerid,
-- 		SUM(hr) as hr
-- 	FROM batting
-- 	WHERE yearid = 2016
-- 		AND hr > 0
-- 	GROUP BY playerid
-- ),
-- -- players with more than 10 years in league, 3475
-- league_10 AS (
-- 	SELECT DISTINCT
-- 		playerid,
-- 		COUNT(DISTINCT yearid)
-- 		--using 'MAX(yearid) - MIN(yearid) AS years_played' and 'HAVING (MAX(yearid) - MIN(yearid)) >= 10' is not correct, as it doesn't account for the fact that some people could have played over a span of 10 years, but not actually active the whole time
-- 	FROM batting
-- 	GROUP BY playerid
-- 	HAVING COUNT(DISTINCT yearid) >= 10
-- ),
-- -- to get MAX, using two queries
-- hr_by_year AS (
-- SELECT
-- 	playerid,
-- 	yearid,
-- 	SUM(hr) AS hr
-- FROM batting
-- GROUP BY playerid, yearid
-- ),
-- max_hr_overall AS (
-- SELECT
-- 	playerid,
-- 	MAX(hr) AS hr
-- FROM hr_by_year
-- GROUP BY playerid
-- )
-- SELECT
-- 	people.playerid, 
-- 	hr_in_2016.hr,
-- 	people.namefirst,
-- 	people.namelast
-- FROM hr_in_2016
-- INNER JOIN league_10
-- USING(playerid)
-- INNER JOIN max_hr_overall
-- USING(playerid, hr)
-- INNER JOIN people
-- USING(playerid);
