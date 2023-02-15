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
