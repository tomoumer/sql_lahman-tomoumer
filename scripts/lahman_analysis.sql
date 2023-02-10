-- 1. Find all players in the database who played at Vanderbilt University. Create a list showing each player's first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
-- a: David Price with $81 million USD!

/* using code below I waws able to find out Vanderbilt University is called 'vandy'
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
-- /* this part was superfluous!
-- FROM people
-- --LEFT JOIN fielding
-- USING(playerid)*/
-- FROM fielding
-- WHERE yearid = 2016
-- GROUP BY position_group;

-- 3. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends? (NOTE: see helpful links in the README)
-- a: it appears the average strikeouts has been steadily increasing over the years - almost 100 years later it essentially trippled!

-- WITH decades AS (
-- 	SELECT generate_series(1920, 2010, 10) AS begin_decade,
-- 		generate_series(1929, 2019, 10) AS end_decade
-- )
-- SELECT
-- 	begin_decade,
-- 	end_decade,
-- 	ROUND(AVG((SO+SOA)::NUMERIC / G), 2) AS average_strikeouts,
-- 	ROUND(AVG((HR+HRA)::NUMERIC / G), 2) AS average_homeruns
-- FROM decades
-- LEFT JOIN teams
-- ON yearid >= begin_decade
-- AND yearid <= end_decade
-- GROUP BY begin_decade, end_decade
-- ORDER BY begin_decade;

-- 4. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases. Report the players' names, number of stolen bases, number of attempts, and stolen base percentage.
-- note: attempts are stolen bases (sb) + caught stealing (cs). By groupingby playerid I also ensured that the resulting join with those limits doesn't have duplicate players (when they played for multiple teams)
-- A: Chris Owings

-- SELECT
-- 	namefirst,
-- 	namelast,
-- 	sb AS stolen_bases,
-- 	sb+cs AS num_attempts,
-- 	ROUND(100.*sb/(sb+cs),2) AS stolen_percentage
-- FROM people
-- INNER JOIN batting
-- USING(playerid)
-- WHERE yearid=2016
-- 	AND sb + cs >= 20
-- ORDER BY stolen_percentage DESC;
-- GROUP BY playerid;

-- 5. From 1970 to 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion; determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 to 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
-- A: largest wins while not winning world 116, smallest wins while winning world is 63 
-- Found out that the strange year was 1981 - In 1981 major league baseball shut down for 50 days from June 12 to August 10. During that time a total of 713 games were lost. The reason behind the strike was free agent player compensation.
-- A: I believe that 12 times the team with most wins also won the world series; 23% of the time

-- SELECT MAX(W)
-- FROM teams
-- WHERE yearid BETWEEN 1970 AND 2016
-- 	AND wswin ='N';

-- SELECT *
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
-- 		AND yearid <> 1981
-- 	GROUP BY yearid
-- )	
-- SELECT 
-- 	SUM(CASE WHEN (max_w IS NOT NULL AND wswin ='Y') THEN 1 END) AS win_win,
-- 	ROUND(100.* SUM(CASE WHEN (max_w IS NOT NULL AND wswin ='Y') THEN 1 END) / (2016 - 1970),2) AS fraction_win
-- FROM teams t
-- LEFT JOIN year_wins
-- ON t.yearid = year_wins.yearid
-- 	AND t.W = year_wins.max_w;

-- SUM(CASE WHEN (max_w IS NOT NULL) THEN 1 END) doesnt work because there are multiple teams with max wins

/* Monica's code
WITH w_rank AS(	SELECT teamid,
			   		   name,
					   yearid,
					   RANK() OVER(PARTITION BY yearid ORDER BY w DESC)
				FROM teams
			  	WHERE yearid >= 1970),
	 ws_wins AS(SELECT teamid, yearid
				FROM teams
				WHERE wswin = 'Y'
					AND yearid >= 1970	)
SELECT COUNT(*) AS count_ws_max_w_teams,
	   ROUND(COUNT(*) * 100.0 / (2016-1969), 2) AS percent_ws_max_w_teams
FROM w_rank
	 INNER JOIN ws_wins 
	 USING(teamid, yearid)
WHERE rank = 1;
*/

-- 6. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

/* first attempt was getting me two columns with years aaand that was no good.
WITH winner_managers AS (
	SELECT
		playerid,
		yearid,
		lgid
	FROM awardsmanagers
	WHERE awardid = 'TSN Manager of the Year'
		AND lgid = 'NL'
)
SELECT
	winner_managers.playerid,
	winner_managers.yearid AS NL_win,
	awardsmanagers.yearid AS AL_win,
	teamid
FROM winner_managers
LEFT JOIN awardsmanagers
USING(playerid)
LEFT JOIN managers
	ON awardsmanagers.playerid = managers.playerid
	AND (winner_managers.yearid = managers.yearid OR
		awardsmanagers.yearid = managers.yearid)
WHERE awardid = 'TSN Manager of the Year'
	AND awardsmanagers.lgid = 'AL';
*/

-- SELECT
-- 	namefirst,
-- 	namelast,
-- 	awmg.yearid,
-- 	awmg.lgid,
-- 	teamid
-- FROM awardsmanagers AS awmg
-- LEFT JOIN people
-- USING(playerid)
-- LEFT JOIN managers AS m
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
-- )

-- 7. Which pitcher was the least efficient in 2016 in terms of salary / strikeouts? Only consider pitchers who started at least 10 games (across all teams). Note that pitchers often play for more than one team in a season, so be sure that you are counting all stats for each player.

-- SELECT 
-- 	playerid,
-- 	SUM(so) AS tot_strikeouts,
-- 	SUM(salary) AS tot_salary
-- FROM pitching p
-- LEFT JOIN salaries
-- USING (playerid)
-- WHERE p.yearid = 2016
--  	AND salaries.yearid = 2016
-- GROUP BY playerid
-- HAVING SUM(g) > 10

-- 8. Find all players who have had at least 3000 career hits. Report those players' names, total number of hits, and the year they were inducted into the hall of fame (If they were not inducted into the hall of fame, put a null in that column.) Note that a player being inducted into the hall of fame is indicated by a 'Y' in the **inducted** column of the halloffame table.