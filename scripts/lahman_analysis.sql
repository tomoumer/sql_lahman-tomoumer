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
-- note: attempts are stolen bases (sb) + caught stealing (cs). By groupingby playerid I also ensured that the resulting join with those limits doesn't have duplicate players (when they played for multiple teams)
-- A: Chris Owings
-- NOTE, needed to group in batting because same player might change teams

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

-- WITH career AS (
-- 	SELECT
-- 		playerid,
-- 		SUM(h) as career_hits
-- 	FROM people
-- 	LEFT JOIN batting
-- 	USING(playerid)
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
-- 	playerid,
-- 	career_hits,
-- 	yearid AS year_inducted
-- FROM career
-- LEFT JOIN hall_inducted
-- USING(playerid)

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
-- SELECT playerid,
-- 		namefirst,
-- 		namelast
-- FROM over_1000_hits
-- INNER JOIN people
-- USING (playerid)
-- GROUP BY playerid , namefirst, namelast
-- HAVING COUNT(*) > 1;

--10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.
-- a: I might have to double check this complex ex!

-- -- at least one hr in 2016, 542 players
-- WITH hr_in_2016 AS (
-- 	SELECT
-- 		playerid,
-- 		SUM(hr) as tot_hr
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
-- 	SUM(hr) AS tot_hr
-- FROM batting
-- GROUP BY playerid, yearid
-- ),
-- max_hr_overall AS (
-- SELECT
-- 	playerid,
-- 	MAX(tot_hr) AS max_hr
-- FROM hr_by_year
-- GROUP BY playerid
-- )
-- SELECT
-- 	people.playerid, 
-- 	hr_in_2016.tot_hr,
-- 	people.namefirst,
-- 	people.namelast
-- FROM hr_in_2016
-- INNER JOIN league_10
-- USING(playerid)
-- INNER JOIN max_hr_overall
-- 	ON max_hr_overall.playerid = hr_in_2016.playerid
-- 	AND max_hr_overall.max_hr = hr_in_2016.tot_hr
-- INNER JOIN people
-- ON hr_in_2016.playerid = people.playerid;

-- ====== BONUS QUESTIONS

-- 1. In this question, you'll get to practice correlated subqueries and learn about the LATERAL keyword. Note: This could be done using window functions, but we'll do it in a different way in order to revisit correlated subqueries and see another keyword - LATERAL.

-- a. First, write a query utilizing a correlated subquery to find the team with the most wins from each league in 2016.

-- SELECT DISTINCT 
-- 	lgid,
-- 	(SELECT teamid 
-- 	FROM teams
-- 	WHERE yearid = 2016
-- 	AND lgwin = 'Y'
-- 	AND lgid = t.lgid) AS teamid
-- FROM teams t
-- WHERE yearid = 2016;

-- b. One downside to using correlated subqueries is that you can only return exactly one row and one column. This means, for example that if we wanted to pull in not just the teamid but also the number of wins, we couldn't do so using just a single subquery. (Try it and see the error you get). Add another correlated subquery to your query on the previous part so that your result shows not just the teamid but also the number of wins by that team.

-- SELECT DISTINCT 
-- 	lgid,
-- 	(SELECT teamid
-- 	FROM teams
-- 	WHERE yearid = 2016
-- 	AND lgwin = 'Y'
-- 	AND lgid = t.lgid) AS teamid,
-- 	(SELECT w
-- 	FROM teams
-- 	WHERE yearid = 2016
-- 	AND lgwin = 'Y'
-- 	AND lgid = t.lgid) AS wins
-- FROM teams t
-- WHERE yearid = 2016;

-- ======= BONUS - window functions

-- Question 1a: Warmup Question
-- Write a query which retrieves each teamid and number of wins (w) for the 2016 season. Apply three window functions to the number of wins (ordered in descending order) - ROW_NUMBER, RANK, AND DENSE_RANK. Compare the output from these three functions. What do you notice?
-- a: row_number simply numbers them; rank and dense_rank have ties and between them it changes what the next number is (e.g. rank will do 2-2-4, dense_rank 2-2-3)

-- SELECT
-- 	teamid,
-- 	w AS wins,
-- 	ROW_NUMBER() OVER(ORDER BY w DESC),
-- 	RANK() OVER(ORDER BY w DESC),
-- 	DENSE_RANK() OVER(ORDER BY w DESC)
-- FROM teams t
-- WHERE yearid = 2016;

-- Question 1b: 
-- Which team has finished in last place in its division (i.e. with the least number of wins) the most number of times? A team's division is indicated by the divid column in the teams table.

-- WITH division_ranking AS (
-- SELECT teamid,
-- 	divid,
-- 	w AS wins,
-- 	RANK() OVER(PARTITION BY divid
--				ORDER BY w)
-- FROM teams t
-- WHERE divid IS NOT NULL
-- )
-- SELECT *
-- FROM division_ranking
-- WHERE rank=1;

-- Question 2a: 
-- Barry Bonds has the record for the highest career home runs, with 762. Write a query which returns, for each season of Bonds' career the total number of seasons he had played and his total career home runs at the end of that season. (Barry Bonds' playerid is bondsba01.)

-- SELECT playerid,
-- 		yearid,
-- 	RANK() OVER(PARTITION BY playerid
-- 					  ORDER BY yearid) AS num_seasons_played,
-- 	SUM(hr) OVER(PARTITION BY playerid
-- 				 ORDER BY yearid) AS career_total_hr
-- FROM batting
-- WHERE playerid = 'bondsba01';

-- Question 2b:
-- How many players at the end of the 2016 season were on pace to beat Barry Bonds' record? For this question, we will consider a player to be on pace to beat Bonds' record if they have more home runs than Barry Bonds had the same number of seasons into his career. 

-- NOTE: have to use dense rank as some players switch teams and appear multiple times for same season

-- WITH ranked_players AS (
-- 	SELECT playerid,
-- 		yearid,
-- 		DENSE_RANK() OVER(PARTITION BY playerid
-- 						  ORDER BY yearid) AS num_seasons_played,
-- 		SUM(hr) OVER(PARTITION BY playerid
-- 					 ORDER BY yearid) AS career_total_hr
-- 	FROM batting
-- 	WHERE playerid <> 'bondsba01'
-- ),
-- ranked_bondsba AS (
-- 	SELECT playerid,
-- 			yearid,
-- 		RANK() OVER(PARTITION BY playerid
-- 						  ORDER BY yearid) AS num_seasons_played,
-- 		SUM(hr) OVER(PARTITION BY playerid
-- 					 ORDER BY yearid) AS bonds_total_hr
-- 	FROM batting
-- 	WHERE playerid = 'bondsba01'
-- )
-- SELECT COUNT(DISTINCT rp.playerid)
-- 	/* these rows were for verification
-- 	rp.num_seasons_played,
-- 	rp.career_total_hr,
-- 	rb.bonds_total_hr*/
-- FROM ranked_players rp
-- LEFT JOIN ranked_bondsba rb
-- USING(num_seasons_played)
-- WHERE career_total_hr > bonds_total_hr
-- AND rp.yearid=2016;

-- #### Question 2c: 
-- Were there any players who 20 years into their career who had hit more home runs at that point into their career than Barry Bonds had hit 20 years into his career? 
-- a: yes, aaronha01, or, Hank Aaron

-- WITH ranked_players AS (
-- 	SELECT playerid,
-- 		yearid,
-- 		DENSE_RANK() OVER(PARTITION BY playerid
-- 						  ORDER BY yearid) AS num_seasons_played,
-- 		SUM(hr) OVER(PARTITION BY playerid
-- 					 ORDER BY yearid) AS career_total_hr
-- 	FROM batting
-- 	WHERE playerid <> 'bondsba01'
-- ),
-- ranked_bondsba AS (
-- 	SELECT playerid,
-- 			yearid,
-- 		RANK() OVER(PARTITION BY playerid
-- 						  ORDER BY yearid) AS num_seasons_played,
-- 		SUM(hr) OVER(PARTITION BY playerid
-- 					 ORDER BY yearid) AS bonds_total_hr
-- 	FROM batting
-- 	WHERE playerid = 'bondsba01'
-- )
-- SELECT 
-- 	p.namefirst,
-- 	p.namelast,
-- 	rp.playerid,
-- 	rp.num_seasons_played,
-- 	rp.career_total_hr,
-- 	rb.bonds_total_hr
-- FROM ranked_players rp
-- INNER JOIN ranked_bondsba rb
-- USING(num_seasons_played)
-- INNER JOIN people p
-- ON rp.playerid=p.playerid
-- WHERE num_seasons_played = 20
-- AND career_total_hr > bonds_total_hr

-- Question 3: Anomalous Seasons
-- Find the player who had the most anomalous season in terms of number of home runs hit. To do this, find the player who has the largest gap between the number of home runs hit in a season and the 5-year moving average number of home runs if we consider the 5-year window centered at that year (the window should include that year, the two years prior and the two years after).
-- a: trumbma01 with 33.20

-- SELECT playerid,
-- 		yearid,
-- 		hr,
-- 		DENSE_RANK() OVER(PARTITION BY playerid
-- 						  ORDER BY yearid) AS num_seasons_played,
-- 		ROUND(AVG(hr) OVER(ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING),2) AS five_yr_hr,
-- 		hr - ROUND(AVG(hr) OVER(ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING),2) AS difference
-- FROM batting
-- ORDER BY difference DESC