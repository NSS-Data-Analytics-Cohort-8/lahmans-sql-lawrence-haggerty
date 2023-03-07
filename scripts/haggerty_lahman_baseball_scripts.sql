SELECT *
FROM people;

-- ## Lahman Baseball Database Exercise
-- - this data has been made available [online](http://www.seanlahman.com/baseball-archive/statistics/) by Sean Lahman
-- - you can find a data dictionary [here](http://www.seanlahman.com/files/database/readme2016.txt)

-- ### Use SQL queries to find answers to the *Initial Questions*. If time permits, choose one (or more) of the *Open-Ended Questions*. Toward the end of the bootcamp, we will revisit this data if time allows to combine SQL, Excel Power Pivot, and/or Python to answer more of the *Open-Ended Questions*.



-- **Initial Questions**

-- 1. What range of years for baseball games played does the provided database cover? 

--ANSWER: This database contains statistics for Major League Baseball from 1871 through 2016.(Data Dictionary / Read Me)...Review of homgames table confirms 1871 - 2016. 

SELECT 
	MIN(year) AS min_year,
	MAX(year) AS max_year
FROM homegames;

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT 
	p.playerid,
	p.namelast,
	p.namefirst,
	MIN(p.height) AS min_height,
	a.g_all,
	t.name
FROM people AS p
LEFT JOIN appearances AS a
USING (playerid)
LEFT JOIN teams AS t
ON a.teamid=t.teamid
GROUP BY p.namelast, p.namefirst, t.name, a.g_all, p.playerid
ORDER BY min_height ASC
LIMIT 1;
--ANSWER: Name: "Gaedel""Eddie", Height: 43, Games Played: 1, Team: "St. Louis Browns" "gaedeed01"

SELECT *
FROM appearances AS a
WHERE playerid = 'gaedeed01';
--Follow-up review


 
-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

-- SELECT 
-- 	p.playerid,
-- 	CONCAT(p.namelast,', ',p.namefirst) AS name,
-- 	s.schoolname,
-- 	SUM(COALESCE(sal.salary,0)::NUMERIC) AS total_salary
-- FROM people AS p
-- INNER JOIN collegeplaying AS cp
-- ON p.playerid=cp.playerid
-- INNER JOIN schools AS s
-- ON cp.schoolid=s.schoolid
-- INNER JOIN salaries AS sal
-- ON p.playerid=sal.playerid 
-- WHERE s.schoolname = 'Vanderbilt University' 
-- GROUP BY p.nameLast, p.namefirst, s.schoolname, p.playerid
-- ORDER BY total_salary DESC;
--Query Returns... "Price, David"	"Vanderbilt University"	$245,553,888
--RELOOK....total salary may be calculated incorrectly....
	
SELECT
	playerid,
	SUM(salary) AS total_salary
FROM SALARIES
GROUP BY playerid
ORDER BY total_salary DESC;
--query returns: $81,851,296 for David Price / "priceda01"

SELECT 
	CONCAT(p.namelast,', ',p.namefirst) AS name,
	s.schoolname,
	COALESCE(sal.sum_salary,0)::NUMERIC AS total_salary
FROM people AS p
LEFT JOIN collegeplaying AS cp
ON p.playerid=cp.playerid
LEFT JOIN schools AS s
ON cp.schoolid=s.schoolid
LEFT JOIN 
	(SELECT playerid,
	SUM(salary) AS sum_salary
	FROM salaries
	GROUP by playerid) AS sal
ON p.playerid=sal.playerid
WHERE s.schoolname = 'Vanderbilt University' 
GROUP BY p.nameLast, p.namefirst, s.schoolname, sal.sum_salary
ORDER BY total_salary DESC;
--ANSWER: Price, David / $81,851,296


-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
--putout:A fielder is credited with a putout when he is the fielder who physically records the act of completing an out -- whether it be by stepping on the base for a forceout, tagging a runner, catching a batted ball, or catching a third strike. A fielder can also receive a putout when he is the fielder deemed by the official scorer to be the closest to a runner called out for interference. Catchers -- who record putouts by catching pitches that result in strikeouts -- and first basemen -- who record putouts by catching throws on ground-ball outs -- generally amass the highest putout totals. https://www.mlb.com/glossary/standard-stats/putout

SELECT *
FROM fielding;

SELECT *
FROM people;

--First Run....
-- SELECT
-- 	f.yearid,
-- 	CONCAT(p.namelast,', ',p.namefirst) AS name,
-- 	SUM(f.po) AS player_putout,
-- 	f.pos AS position,
-- 	CASE WHEN f.pos LIKE 'SS' OR f.pos LIKE '1B' OR f.pos LIKE'2B' OR f.pos LIKE '3B' THEN 'infield'
-- 		WHEN f.pos LIKE 'OF' THEN 'outfield'
-- 		WHEN f.pos LIKE 'P' OR f.pos LIKE 'C' THEN 'battery'
-- 		ELSE 'n/a' END AS position_grouping
-- FROM people as p
-- LEFT JOIN fielding as f
-- ON p.playerid=f.playerid
-- WHERE yearid='2016'
-- GROUP BY f.yearid, f.pos, p.namelast, p.namefirst
-- ORDER BY position_grouping, position;
--Reread question......read too much into question...simplify...

SELECT
	SUM(f.po) AS group_putout,
	CASE WHEN f.pos LIKE 'SS' OR f.pos LIKE '1B' OR f.pos LIKE'2B' OR f.pos LIKE '3B' THEN 'infield'
		WHEN f.pos LIKE 'OF' THEN 'outfield'
		WHEN f.pos LIKE 'P' OR f.pos LIKE 'C' THEN 'battery'
		ELSE 'n/a' END AS position_grouping
FROM fielding as f
WHERE yearid='2016'
GROUP BY position_grouping;
--ANSWER: Putouts by Group: battery=41424, outfield=29560, infield=58934
   
-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT *
FROM Teams;

-- SELECT 
-- 	CASE WHEN yearid BETWEEN '1920' AND '1929' THEN '1920s'
-- 		WHEN yearid BETWEEN '1930' AND '1939' THEN '1930s'
-- 		WHEN yearid BETWEEN '1940' AND '1949' THEN '1940s'
-- 		WHEN yearid BETWEEN '1950' AND '1959' THEN '1950s'
-- 		WHEN yearid BETWEEN '1960' AND '1969' THEN '1960s'
-- 		WHEN yearid BETWEEN '1970' AND '1979' THEN '1970s'
-- 		WHEN yearid BETWEEN '1980' AND '1989' THEN '1980s'
-- 		WHEN yearid BETWEEN '1990' AND '1999' THEN '1990s'
-- 		WHEN yearid BETWEEN '2000' AND '2009' THEN '2000s'
-- 		WHEN yearid BETWEEN '2010' AND '2016' THEN '2010s'
-- 		END AS decade,
-- 	ROUND(AVG(so), 2) AS avg_so,
-- 	ROUND(AVG(hr),2) AS avg_hr
-- FROM teams
-- GROUP BY decade
-- ORDER BY decade
-- LIMIT 10;
--Query Not quite right....Need average number of strikeouts per game by decade...Above is SO based on year

-- SELECT *
-- FROM Teams;

-- SELECT 
-- 	yearid,
-- 	SUM(so) AS sum_so,
-- 	SUM(hr) AS sum_hr,
-- 	SUM(g) AS sum_g
-- FROM teams
-- WHERE yearid BETWEEN '1920' AND '2016'
-- GROUP BY yearid 
-- ORDER BY yearid;
--needs work???


-- SELECT 
-- 	yearid,
-- 	ROUND(SUM(so)/SUM(g), 2) AS avg_so,
-- 	ROUND(SUM(hr)/SUM(g), 2) AS avg_hr
-- FROM teams
-- WHERE yearid BETWEEN '1920' AND '2016' 
-- GROUP BY yearid 
-- ORDER BY yearid;
--Thinking my way through...Division Does Not Seem to Calculate Correctly???...Look at Character Type

SELECT 
		CASE WHEN yearid BETWEEN '1920' AND '1929' THEN '1920s'
		WHEN yearid BETWEEN '1930' AND '1939' THEN '1930s'
		WHEN yearid BETWEEN '1940' AND '1949' THEN '1940s'
		WHEN yearid BETWEEN '1950' AND '1959' THEN '1950s'
		WHEN yearid BETWEEN '1960' AND '1969' THEN '1960s'
		WHEN yearid BETWEEN '1970' AND '1979' THEN '1970s'
		WHEN yearid BETWEEN '1980' AND '1989' THEN '1980s'
		WHEN yearid BETWEEN '1990' AND '1999' THEN '1990s'
		WHEN yearid BETWEEN '2000' AND '2009' THEN '2000s'
		WHEN yearid BETWEEN '2010' AND '2016' THEN '2010s'
		END AS decade,
		SUM(so) AS sum_so,
		SUM(hr) AS sum_hr,
		SUM(g) AS sum_g,
		ROUND(SUM(so)::NUMERIC/SUM(g)::NUMERIC,2) AS avg_so,
		ROUND(SUM(hr)::NUMERIC/SUM(g)::NUMERIC,2) AS avg_hr
FROM teams
GROUP BY decade
ORDER BY decade
LIMIT 10;
--ANSWER: Query Above Returns AVG SO and HR by Decade!
   

-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

-- SELECT *
-- FROM Batting;
--NOTE: CS & SB Contain NULLs / Character Type Integer

-- SELECT *
-- FROM People;

SELECT
	CONCAT(p.namelast,', ',p.namefirst) AS name,
	SUM(CS) AS sum_cs,
	SUM(sb) AS sum_sb,
	SUM(cs)+SUM(SB) AS atmpt_stl,
	ROUND(SUM(sb)::NUMERIC/(SUM(cs)+SUM(SB))::NUMERIC*100,2) AS prct_success
FROM people as p
LEFT JOIN batting as b
ON p.playerid=b.playerid
GROUP BY name, b.yearid
HAVING b.yearid='2016' AND SUM(cs)+SUM(SB) >= '20'
ORDER by prct_success DESC;
--ANSWER: "Owings, Chris" / Prct 91.30....21 successful of 23 attempts

-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

-- SELECT *
-- FROM teams;
--Review Table

-- SELECT 
-- 	yearid,
-- 	name,
-- 	w,
-- 	l,
-- 	COALESCE(wswin, 'NA') AS wswin,
-- 	SUM(w) AS wins,
-- 	SUM(l) AS loses
-- FROM teams as t
-- WHERE yearid BETWEEN '1970' AND '2016'
-- GROUP BY yearid, name, wswin, w, l
-- ORDER BY yearid, wins;
--First Run
--w & l already compiled for year...SUM is not necessary
--1981 & 1994 MLB Strike....1994 World Series Cancelled Due to MLB Player Strike


SELECT
	yearid,
	name, 
	w,
	MAX(MAX(w)) OVER() AS max_window
FROM teams
WHERE wswin='N' 
AND yearid BETWEEN '1970' AND '2016'
GROUP BY yearid, name, w
HAVING MAX(w) = (SELECT MAX(MAX(w)) OVER() AS max_window FROM teams)
ORDER BY yearid;
--OVERKILL...MAX(MAX not required...Overthinking the problem 
--ANSWER 7A: largest wins w/o ws win: 2001, Seattle Mariners, 116 wins

SELECT 
	yearid, 
	name,
	w,
	MAX(w),
	wswin
FROM teams
WHERE wswin='N' 
AND yearid BETWEEN '1970' AND '2016'
GROUP BY yearid, name, w, wswin
ORDER BY MAX(w) DESC;
--REWORK OF QUERY ABOVE....MAX(MAX not required...Worked, but Overthinking the problem 
--ANSWER 7A: 2001 / Seattle Mariners / 116 wins

SELECT
	yearid,
	name, 
	w,
	MIN(w)AS min_window,
	wswin
FROM teams
WHERE wswin='Y' 
AND yearid BETWEEN '1970' AND '2016'
GROUP BY yearid, name, w, wswin
ORDER BY w;
--ANSWER 7B: 1981 / Los Angeles Dodgers / 63 (Year of Strike...Disregard Result), Next Team: 2006 / St. Louis Cardinals / 83

--Working IT...How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

-- SELECT 
-- 	yearid,
-- 	name,
-- 	w AS win,
-- 	l AS loss,
-- 	COALESCE(wswin, 'NA') AS wswin
-- FROM teams as t
-- WHERE yearid BETWEEN '1970' AND '2016'
-- GROUP BY yearid, name, wswin, w, l
-- HAVING w= (SELECT MAX(MAX(w)) OVER() AS max_window FROM teams)
-- ORDER BY yearid, win;
--RETURNS SINGLE LINE w/ HIGHEST MAX WINS AND NO WSWIN for TEAMS TABLE

--cte drill
-- WITH cte AS(SELECT MAX(w) AS max, yearid --MAX wins each year 
-- 		   FROM teams
-- 		   WHERE yearid BETWEEN 1970 AND 2016
-- 		   GROUP BY yearid
-- 		   ORDER BY yearid),
-- 	cte2 AS (
-- 		SELECT wswin,teamid
-- 		FROM teams
-- 		WHERE wswin = 'Y' AND yearid BETWEEN 1970 AND 2016)
-- SELECT teamid, teams.wswin
-- FROM teams
-- INNER JOIN cte
-- USING (yearid)
-- INNER JOIN cte2
-- USING (teamid)
-- WHERE teams.wswin='Y'
-- GROUP BY teams.teamid, teams.wswin;
--INFO RETURNED NOT USEFUL....DOES NOT APPEAR CORRECT
---Break

--...How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
WITH cte1 AS(
	SELECT MAX(w) AS max, yearid --MAX wins each year 
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
	GROUP BY yearid
	ORDER BY yearid),
 cte2 AS (
	SELECT 
 	t.yearid,
 	t.teamid,
	t.wswin,
	t.w,
	cte1.max
	FROM teams AS t
	INNER JOIN cte1
	ON t.w=cte1.max AND t.yearid=cte1.yearid
	WHERE t.yearid BETWEEN 1970 AND 2016 AND wswin = 'Y')
SELECT
	--t1.yearid,
	--t1.name,
	--t1.w,
	COUNT (t1.*) AS t1_count,
	COUNT(cte1.*) AS cte1_count,
	COUNT(cte2.max) AS max_win_w_ws_win,
	ROUND(COUNT(cte1.*)::NUMERIC / COUNT(t1.*)::NUMERIC,2)*100 AS max_win_prcnt
FROM teams AS t1
LEFT JOIN cte1
ON t1.w=cte1.max AND t1.yearid=cte1.yearid
LEFT JOIN cte2
ON t1.w=cte2.w AND t1.yearid=cte2.yearid
WHERE t1.yearid BETWEEN 1970 AND 2016 AND t1.wswin = 'Y'
--GROUP BY t1.yearid, t1.name, t1.w, cte2.max
--ANSWERS 7C: Max Wins w/ WSWIN=12, Percent=26


--QC Check of the 7C results returned above...
WITH cte1 AS(
	SELECT MAX(w) AS max, yearid --MAX wins each year 
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
	GROUP BY yearid
	ORDER BY yearid),
 cte2 AS (
	SELECT 
 	t.yearid,
 	t.teamid,
	t.wswin,
	t.w,
	cte1.max
	FROM teams AS t
	INNER JOIN cte1
	ON t.w=cte1.max AND t.yearid=cte1.yearid
	WHERE t.yearid BETWEEN 1970 AND 2016 AND wswin = 'Y')
SELECT
	t1.yearid,
	t1.name,
	t1.w,
	COUNT (t1.*) AS t1_count,
	COUNT(cte1.yearid) AS cte1_count,
	COUNT(cte2.max) AS max_win_w_ws_win
	--ROUND(COUNT(cte1.*)::NUMERIC / COUNT(t1.*)::NUMERIC,2)*100 AS max_win_prcnt
FROM teams AS t1
LEFT JOIN cte1
ON t1.w=cte1.max AND t1.yearid=cte1.yearid
LEFT JOIN cte2
ON t1.w=cte2.w AND t1.yearid=cte2.yearid
WHERE t1.yearid BETWEEN 1970 AND 2016 AND t1.wswin = 'Y'
GROUP BY t1.yearid, t1.name, t1.w, cte2.max;
--SELECT 4X Years and Teams to Crosscheck for accuracy...
	---1970 Baltimore Orioles / 1975 Cincinatti Reds / 1980 Philadelhia Phillies / 1995 Atlanta Braves
	---Above Verifies Correct
---Use for manual check of MAX WINs and WSWIN
SELECT 
	yearid, name, w, wswin
FROM teams
WHERE yearid=2013
ORDER BY w DESC;

-- CORRECT 12 Teams with Top Wins and WS Win from 1970-2016
--SELECT ROUND(12::NUMERIC/46::NUMERIC*100,2) AS Percent

--***1970 Baltimore Orioles as Top Wins (108) and WS Win
--***1975 Cincinatti Reds as Top Wins (108) and WS Win
--***1976 Cincinatti Reds as Top Wins (102) and WS Win
--***1978 New York Yankees as Top Wins (100) and WS Win
--***1984 Detroit Tigers as Top Wins (104) and WS Win
--***1986 New York Mets as Top Wins (108) and WS Win
--***1989 Oakland Athletics as Top Wins (99) and WS Win
--***1998 New York Yankees as Top Wins (114) and WS Win
--***2007 Boston Red Sox as Top Wins (96) and WS Win
--***2009 New York Yankees as Top Wins (103) and WS Win
--***2013 St. Louis Cardinals / Boston Red SOX -TIE- as Top Wins (97) and Red Sox as WS winner (97 Wins)
--***2016 Chicago Cubs as Top Wins (103) and WS Win

-- SELECT
-- 	DISTINCT yearid,
-- 	MAX(w)::BIT AS max_w_bit, 
-- 	MAX(w)::NUMERIC AS max_w_num
-- FROM teams 
-- WHERE yearid = 1970 
-- GROUP BY w, yearid
--HAVING MAX(w)::BIT='1'
---Keep Working It...This was not useful...Attempt to CAST as BIT to return 0 or 1. Did not work well. 

--Alternate QUERies for 7C
WITH cte1 AS
(SELECT
	yearid,
	teamid,
	w,
	wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 

GROUP BY yearid, teamid, w, wswin),
--Returns 46 fields covering WS winners 1970-2016
cte2 AS
(SELECT
	yearid,
	MAX(W) AS max_w
FROM TEAMS
GROUP BY yearid 
ORDER BY yearid)
--Returns 1 field per year
SELECT
	t1.yearid,
	t1.name,
	c2.max_w
	--(SELECT ROUND(COUNT(c2.max_w)::NUMERIC / COUNT(cte1.*)::NUMERIC,2)*100 FROM cte1,cte2) AS max_w_prcnt
FROM teams AS t1
LEFT JOIN cte1 AS c1
ON t1.yearid=c1.yearid AND t1.w=c1.w
LEFT JOIN cte2 AS c2
ON t1.yearid=c2.yearid AND t1.w=c2.max_w
WHERE t1.yearid BETWEEN 1970 AND 2016 
AND t1.wswin='Y'
AND c2.max_w IS NOT NULL
GROUP BY t1.yearid, t1.name, c2.max_w
ORDER BY t1.yearid;
--Using LEFT JOIN includes NULLS in max_w column...fields w/ numbers are accurate
--INNER JOIN returns 12 field w/ NO NULLS
--Confirms Manual Check of Top Wins & WS Win

--Query that Answers Part C
WITH cte1 AS
(SELECT
	yearid,
	teamid,
	w,
	wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 
AND wswin='Y'
GROUP BY yearid, teamid, w, wswin),
--Returns 46 fields covering WS winners 1970-2016
cte2 AS
(SELECT
	yearid,
	MAX(W) AS max_w
FROM TEAMS
GROUP BY yearid 
ORDER BY yearid)
--Returns 1 field per year
SELECT
	COUNT(c2.max_w) AS max_win_w_wswin,
	ROUND(COUNT(c2.*)::NUMERIC / COUNT(c1.*)::NUMERIC,4)*100 AS max_w_win_prcnt
FROM teams AS t1
LEFT JOIN cte1 AS c1
ON t1.yearid=c1.yearid AND t1.w=c1.w
LEFT JOIN cte2 AS c2
ON t1.yearid=c2.yearid AND t1.w=c2.max_w
WHERE t1.yearid BETWEEN 1970 AND 2016 
AND t1.wswin='Y';
--Additional / Alternate Query..ANSWER 7C: 12 Teams w/ Top Wins as WS win 1970-2016....Percentage 26.09


-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT *
FROM homegames;

SELECT *
FROM teams;

SELECT
	h.park,
	t.name,
	ROUND((h.attendance::NUMERIC/h.games::NUMERIC),0) AS avg_attnd
FROM homegames AS h
--INNER JOIN teams AS t
--ON h.team=t.teamid AND h.year=t.yearid
LEFT JOIN teams AS t
ON h.team=t.teamid AND h.year=t.yearid
WHERE year=2016 AND games>=10
ORDER BY avg_attnd DESC
LIMIT 5;
--ANSWER 8A: Query returns Top 5 Avg Attendance Parks w/ Team Name and Attendance Count

SELECT
	h.park,
	t.name,
	ROUND((h.attendance::NUMERIC/h.games::NUMERIC),0) AS avg_attnd
FROM homegames AS h
--INNER JOIN teams AS t
--ON h.team=t.teamid AND h.year=t.yearid
LEFT JOIN teams AS t
ON h.team=t.teamid AND h.year=t.yearid
WHERE year=2016 AND games>=10
ORDER BY avg_attnd ASC
LIMIT 5;
--ANSWER 8B: Query returns Bottom 5 Avg Attendance Parks w/ Team Name and Attendance Count

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

SELECT *
FROM teams;

SELECT *
FROM people;

SELECT *
FROM awardsmanagers;

SELECT *
FROM managers;

-- SELECT
-- 	DISTINCT p.namelast,
-- 	p.namefirst,
-- 	am.yearid,
-- 	am.lgid,
-- 	am.awardid,
-- 	t.name AS tm_name
-- FROM awardsmanagers AS am
-- LEFT JOIN teams AS t
-- ON am.lgid=t.lgid AND am.yearid=t.yearid
-- LEFT JOIN people AS p
-- ON p.playerid=am.playerid
-- WHERE am.lgid IN ('AL','NL') AND am.awardid LIKE 'TSN Manager of the Year'
-- GROUP BY am.lgid, p.namelast, p.namefirst, am.awardid, t.name, am.yearid
-- ORDER BY namelast
-- --WHERE am.lgid LIKE 'AL' AND am.lgid LIKE 'NL' AND 

--Test Query for Info
SELECT 
	playerid,
	awardid,
	yearid, 
	lgid
	FROM awardsmanagers
	WHERE  awardid LIKE 'TSN Manager of the Year' AND lgid NOT LIKE 'ML'
	ORDER BY playerid, lgid;
--Returns 60 rows with AL & NL TSN MoY winners

WITH cte1 AS
	(SELECT 
	playerid,
	awardid,
	yearid, 
	lgid
	FROM awardsmanagers
	WHERE  awardid LIKE 'TSN Manager of the Year' AND lgid NOT LIKE 'ML' AND lgid NOT LIKE 'NL'),
	 cte2 AS
	(SELECT 
	playerid,
	awardid,
	--yearid, 
	lgid
	FROM awardsmanagers
	WHERE  awardid LIKE 'TSN Manager of the Year' AND lgid NOT LIKE 'ML' AND lgid NOT LIKE 'AL'),
	 cte3 AS
	 (SELECT
		playerid,
	 	CONCAT(namelast,', ',namefirst) AS name
	 FROM people),
	 cte4 AS
	 (SELECT 
	 	yearid,
	 	lgid,
	 	name
	 FROM Teams)
SELECT
	 --cte1.yearid AS al_awd_year,
 	 --cte2.yearid AS nl_awd_year,
 	 cte1.lgid AS al_awd_win,
 	 cte2.lgid AS nl_awd_win,
	 cte3.name AS name,
	 cte4.name AS team
FROM awardsmanagers as am
LEFT JOIN cte1
ON am.playerid=cte1.playerid AND am.yearid=cte1.yearid
LEFT JOIN cte2
ON am.playerid=cte2.playerid --AND am.yearid=cte2.yearid
LEFT JOIN cte3
ON am.playerid=cte3.playerid
LEFT JOIN cte4
ON am.lgid=cte4.lgid AND am.yearid=cte4.yearid
WHERE cte1.playerid=cte2.playerid AND cte1.awardid=cte2.awardid
--WHERE cte1.lgid IS NOT NULL
--AND cte2.lgid IS NOT NULL
GROUP BY cte3.name,cte4.name, cte1.yearid, cte1.lgid, cte2.lgid --, cte2.yearid
--ORDER BY cte1.yearid ASC;
--IDs correct MGRs (Johnson Davey / Leyland Jim) and AWD Years....Does not filter down correctly
--Keep Trying...

--SAVE FOR LATER...
--	 CASE WHEN cte1.awardid='TSN Manager of the Year' THEN 'al_tsn_moy'
--	 	  ELSE 'no' END al_awd,
--	 CASE WHEN cte2.awardid='TSN Manager of the Year' THEN 'nl_tsn_moy'
--	 	  ELSE 'no' END nl_awd,
--

--NEW TRY 1236, 7MAR
WITH cte1 AS
	--Pull Only AL TSN MOY WINNERS
	(SELECT 
	playerid,
	awardid,
	yearid, 
	lgid
	FROM awardsmanagers
	WHERE  awardid LIKE 'TSN Manager of the Year' AND lgid NOT LIKE 'ML' AND lgid NOT LIKE 'NL'),
	 cte2 AS
	 --Pull Only NL TSN MOY WINNERS
	(SELECT 
	playerid,
	awardid,
	yearid, 
	lgid
	FROM awardsmanagers
	WHERE  awardid LIKE 'TSN Manager of the Year' AND lgid NOT LIKE 'ML' AND lgid NOT LIKE 'AL'),
	 cte3 AS
	 --Pull Name
	 (SELECT
		playerid,
	 	CONCAT(namelast,', ',namefirst) AS name
	 FROM people),
	 cte4 AS
	 --Pull Team
	 (SELECT 
	 	yearid,
	 	lgid,
	 	name
	 FROM Teams),
	 cte5 AS
	 --Combined AL-NL TSN MOY Winners
	 (SELECT 
	playerid,
	awardid,
	yearid, 
	lgid
	FROM awardsmanagers
	WHERE  awardid LIKE 'TSN Manager of the Year' AND lgid NOT LIKE 'ML'
	ORDER BY playerid, lgid)
SELECT
	cte3.name AS name,
	 cte4.name AS team
FROM cte5
LEFT JOIN cte1
ON cte5.playerid=cte1.playerid --AND cte5.yearid=cte1.yearid
LEFT JOIN cte2
ON cte5.playerid=cte2.playerid AND cte5.yearid=cte2.yearid 
LEFT JOIN cte3
ON cte5.playerid=cte3.playerid
LEFT JOIN cte4
ON cte5.lgid=cte4.lgid AND cte5.yearid=cte4.yearid
WHERE cte1.playerid=cte2.playerid AND cte1.awardid=cte2.awardid --AND cte1.awardid=cte5.awardid AND cte2.awardid=cte5.awardid
GROUP BY cte3.name, cte4.name --, cte5.playerid
--ORDER BY cte5.playerid


-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.


-- **Open-ended questions**

-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

-- 12. In this question, you will explore the connection between number of wins and attendance.
--     <ol type="a">
--       <li>Does there appear to be any correlation between attendance at home games and number of wins? </li>
--       <li>Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.</li>
--     </ol>


-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?


