# PostgreSQL - exercise 3

This was the third exercise/assignment using [PostgreSQL](https://www.postgresql.org) that each student of the Data Science Bootcamp did. Just like with the other two, there are some unfinished questions (bonus questions) at the end that I didn't solve (yet?), as we moved to other projects - in this particular exercise, there are two sets of them "bonus questions" and lahman "window questions". I created separate scripts for each. We had a review of the code with the class as well, which is when I added some alternative solutions to certain questions.

Note: in order to not have all the querries run at all times, I commented each one out after I completed it.

## Lahman Baseball Database Exercise
- this data has been made available [online](http://www.seanlahman.com/baseball-archive/statistics/) by Sean Lahman
- you can find a data dictionary [here](http://www.seanlahman.com/files/database/readme2016.txt)

1. Find all players in the database who played at Vanderbilt University. Create a list showing each player's first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

2. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

3. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends? (Hint: For this question, you might find it helpful to look at the **generate_series** function (https://www.postgresql.org/docs/9.1/functions-srf.html). If you want to see an example of this in action, check out this DataCamp video: https://campus.datacamp.com/courses/exploratory-data-analysis-in-sql/summarizing-and-aggregating-numeric-data?ex=6)

4. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases. Report the players' names, number of stolen bases, number of attempts, and stolen base percentage.

5. From 1970 to 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion; determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 to 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

6. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

7. Which pitcher was the least efficient in 2016 in terms of salary / strikeouts? Only consider pitchers who started at least 10 games (across all teams). Note that pitchers often play for more than one team in a season, so be sure that you are counting all stats for each player.

8. Find all players who have had at least 3000 career hits. Report those players' names, total number of hits, and the year they were inducted into the hall of fame (If they were not inducted into the hall of fame, put a null in that column.) Note that a player being inducted into the hall of fame is indicated by a 'Y' in the **inducted** column of the halloffame table.

9. Find all players who had at least 1,000 hits for two different teams. Report those players' full names.

10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

After finishing the above questions, here are some open-ended questions to consider.

**Open-ended questions**

11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

12. In this question, you will explore the connection between number of wins and attendance.

    a. Does there appear to be any correlation between attendance at home games and number of wins?  
    b. Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.


13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?


## Lahman Bonus Questions

In these exercises, you'll explore a couple of other advanced features of PostgreSQL. 

1. In this question, you'll get to practice correlated subqueries and learn about the LATERAL keyword. Note: This could be done using window functions, but we'll do it in a different way in order to revisit correlated subqueries and see another keyword - LATERAL.

a. First, write a query utilizing a correlated subquery to find the team with the most wins from each league in 2016.

If you need a hint, you can structure your query as follows:

SELECT DISTINCT lgid, ( <Write a correlated subquery here that will pull the teamid for the team with the highest number of wins from each league> )
FROM teams t
WHERE yearid = 2016;

b. One downside to using correlated subqueries is that you can only return exactly one row and one column. This means, for example that if we wanted to pull in not just the teamid but also the number of wins, we couldn't do so using just a single subquery. (Try it and see the error you get). Add another correlated subquery to your query on the previous part so that your result shows not just the teamid but also the number of wins by that team.

c. If you are interested in pulling in the top (or bottom) values by group, you can also use the DISTINCT ON expression (https://www.postgresql.org/docs/9.5/sql-select.html#SQL-DISTINCT). Rewrite your previous query into one which uses DISTINCT ON to return the top team by league in terms of number of wins in 2016. Your query should return the league, the teamid, and the number of wins.

d. If we want to pull in more than one column in our correlated subquery, another way to do it is to make use of the LATERAL keyword (https://www.postgresql.org/docs/9.4/queries-table-expressions.html#QUERIES-LATERAL). This allows you to write subqueries in FROM that make reference to columns from previous FROM items. This gives us the flexibility to pull in or calculate multiple columns or multiple rows (or both). Rewrite your previous query using the LATERAL keyword so that your result shows the teamid and number of wins for the team with the most wins from each league in 2016. 

If you want a hint, you can structure your query as follows:

SELECT *
FROM (SELECT DISTINCT lgid 
	  FROM teams
	  WHERE yearid = 2016) AS leagues,
	  LATERAL ( <Fill in a subquery here to retrieve the teamid and number of wins> ) as top_teams;
	  
e. Finally, another advantage of the LATERAL keyword over using correlated subqueries is that you return multiple result rows. (Try to return more than one row in your correlated subquery from above and see what type of error you get). Rewrite your query on the previous problem sot that it returns the top 3 teams from each league in term of number of wins. Show the teamid and number of wins.


2. Another advantage of lateral joins is for when you create calculated columns. In a regular query, when you create a calculated column, you cannot refer it it when you create other calculated columns. This is particularly useful if you want to reuse a calculated column multiple times. For example,

SELECT 
	teamid,
	w,
	l,
	w + l AS total_games,
	w*100.0 / total_games AS winning_pct
FROM teams
WHERE yearid = 2016
ORDER BY winning_pct DESC;

results in the error that "total_games" does not exist. However, I can restructure this query using the LATERAL keyword.

SELECT
	teamid,
	w,
	l,
	total_games,
	w*100.0 / total_games AS winning_pct
FROM teams t,
LATERAL (
	SELECT w + l AS total_games
) AS tg
WHERE yearid = 2016
ORDER BY winning_pct DESC;

a. Write a query which, for each player in the player table, assembles their birthyear, birthmonth, and birthday into a single column called birthdate which is of the date type.

b. Use your previous result inside a subquery using LATERAL to calculate for each player their age at debut and age at retirement. (Hint: It might be useful to check out the PostgreSQL date and time functions https://www.postgresql.org/docs/8.4/functions-datetime.html).

c. Who is the youngest player to ever play in the major leagues?

d. Who is the oldest player to player in the major leagues? You'll likely have a lot of null values resulting in your age at retirement calculation. Check out the documentation on sorting rows here https://www.postgresql.org/docs/8.3/queries-order.html about how you can change how null values are sorted.

3. For this question, you will want to make use of RECURSIVE CTEs (see https://www.postgresql.org/docs/13/queries-with.html). The RECURSIVE keyword allows a CTE to refer to its own output. Recursive CTEs are useful for navigating network datasets such as social networks, logistics networks, or employee hierarchies (who manages who and who manages that person). To see an example of the last item, see this tutorial: https://www.postgresqltutorial.com/postgresql-recursive-query/. 
In the next couple of weeks, you'll see how the graph database Neo4j can easily work with such datasets, but for now we'll see how the RECURSIVE keyword can pull it off (in a much less efficient manner) in PostgreSQL. (Hint: You might find it useful to look at this blog post when attempting to answer the following questions: https://data36.com/kevin-bacon-game-recursive-sql/.)

a. Willie Mays holds the record of the most All Star Game starts with 18. How many players started in an All Star Game with Willie Mays? (A player started an All Star Game if they appear in the allstarfull table with a non-null startingpos value).

b. How many players didn't start in an All Star Game with Willie Mays but started an All Star Game with another player who started an All Star Game with Willie Mays? For example, Graig Nettles never started an All Star Game with Willie Mayes, but he did star the 1975 All Star Game with Blue Vida who started the 1971 All Star Game with Willie Mays.

c. We'll call two players connected if they both started in the same All Star Game. Using this, we can find chains of players. For example, one chain from Carlton Fisk to Willie Mays is as follows: Carlton Fisk started in the 1973 All Star Game with Rod Carew who started in the 1972 All Star Game with Willie Mays. Find a chain of All Star starters connecting Babe Ruth to Willie Mays. 

d. How large a chain do you need to connect Derek Jeter to Willie Mays?

## Lahman Window Questions

### Question 1: Rankings
#### Question 1a: Warmup Question
Write a query which retrieves each teamid and number of wins (w) for the 2016 season. Apply three window functions to the number of wins (ordered in descending order) - ROW_NUMBER, RANK, AND DENSE_RANK. Compare the output from these three functions. What do you notice?

#### Question 1b: 
Which team has finished in last place in its division (i.e. with the least number of wins) the most number of times? A team's division is indicated by the divid column in the teams table.

### Question 2: Cumulative Sums
#### Question 2a: 
Barry Bonds has the record for the highest career home runs, with 762. Write a query which returns, for each season of Bonds' career the total number of seasons he had played and his total career home runs at the end of that season. (Barry Bonds' playerid is bondsba01.)

#### Question 2b:
How many players at the end of the 2016 season were on pace to beat Barry Bonds' record? For this question, we will consider a player to be on pace to beat Bonds' record if they have more home runs than Barry Bonds had the same number of seasons into his career. 

#### Question 2c: 
Were there any players who 20 years into their career who had hit more home runs at that point into their career than Barry Bonds had hit 20 years into his career? 

### Question 3: Anomalous Seasons
Find the player who had the most anomalous season in terms of number of home runs hit. To do this, find the player who has the largest gap between the number of home runs hit in a season and the 5-year moving average number of home runs if we consider the 5-year window centered at that year (the window should include that year, the two years prior and the two years after).

### Question 4: Players Playing for one Team
For this question, we'll just consider players that appear in the batting table.
#### Question 4a: 
Warmup: How many players played at least 10 years in the league and played for exactly one team? (For this question, exclude any players who played in the 2016 season). Who had the longest career with a single team? (You can probably answer this question without needing to use a window function.)

#### Question 4b: 
Some players start and end their careers with the same team but play for other teams in between. For example, Barry Zito started his career with the Oakland Athletics, moved to the San Francisco Giants for 7 seasons before returning to the Oakland Athletics for his final season. How many players played at least 10 years in the league and start and end their careers with the same team but played for at least one other team during their career? For this question, exclude any players who played in the 2016 season.

### Question 5: Streaks
#### Question 5a: 
How many times did a team win the World Series in consecutive years?

#### Question 5b: 
What is the longest steak of a team winning the World Series? Write a query that produces this result rather than scanning the output of your previous answer.

#### Question 5c: 
A team made the playoffs in a year if either divwin, wcwin, or lgwin will are equal to 'Y'. Which team has the longest streak of making the playoffs? 

#### Question 5d: 
The 1994 season was shortened due to a strike. If we don't count a streak as being broken by this season, does this change your answer for the previous part?

### Question 6: Manager Effectiveness
Which manager had the most positive effect on a team's winning percentage? To determine this, calculate the average winning percentage in the three years before the manager's first full season and compare it to the average winning percentage for that manager's 2nd through 4th full season. Consider only managers who managed at least 4 full years at the new team and teams that had been in existence for at least 3 years prior to the manager's first full season.