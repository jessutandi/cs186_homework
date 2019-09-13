DROP VIEW IF EXISTS q0, q1i, q1ii, q1iii, q1iv, q2i, q2ii, q2iii, q3i, lslg_view, q3ii, q3iii, q4i, binid_view, q4ii, q4iii, q4iv, q4v;

-- Question 0
CREATE VIEW q0(era)
AS
	SELECT MAX(era)
	FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear) 
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst LIKE '% %'  
		-- using LIKE predicate and the % operator to find strings that contain any other characters before or after a space. 
		-- ref: https://www.c-sharpcorner.com/blogs/how-to-check-if-a-string-contains-a-substring-in-sql-server
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear ASC
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT *
  FROM q1iii
  WHERE avgheight>70
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT p.namefirst, p.namelast, h.playerid, h.yearid
  FROM halloffame AS h, people AS p
  WHERE h.playerid=p.playerid AND inducted='Y'
  ORDER BY yearid DESC 
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT p.namefirst, p.namelast, p.playerid, c.schoolid, p.yearid
  FROM q2i as p, collegeplaying as c, schools as s
  WHERE p.playerid=c.playerid AND c.schoolid=s.schoolid AND s.schoolstate='CA'
  ORDER BY p.yearid DESC, schoolid, p.playerid ASC
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT p.playerid, p.namefirst, p.namelast, c.schoolid
  FROM q2i as p LEFT JOIN collegeplaying as c
  ON p.playerid=c.playerid
  ORDER BY p.playerid DESC, c.schoolid ASC
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT p.playerid, p.namefirst, p.namelast, b.yearid, 
  CAST((b.h-b.h2b-b.h3b-b.hr)+(2*b.h2b)+(3*b.h3b)+(4*b.hr) AS FLOAT)/b.ab AS "slg"
  FROM people as p, batting as b
  WHERE p.playerid=b.playerid AND b.ab>50
  ORDER BY slg DESC, b.yearid, p.playerid ASC
  LIMIT 10
;

-- Question 3ii
CREATE VIEW lslg_view
AS
  SELECT p.playerid, p.namefirst, p.namelast, 
  		(CAST(l.lh1b AS FLOAT) + 2*l.lh2b + 3*l.lh3b + 4*l.lhr)/l.lab AS lslg
  FROM people as p, 
		(SELECT playerid, SUM(h)-SUM(h2b)-SUM(h3b)-SUM(hr) AS "lh1b", 
			SUM(h2b) AS "lh2b", SUM(h3b) AS "lh3b", SUM(hr) AS "lhr",
			SUM(ab) AS "lab"
		FROM batting as b
		GROUP BY playerid) AS l
  WHERE p.playerid=l.playerid AND l.lab>50
  ORDER BY lslg DESC, playerid ASC
;
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT *
  FROM lslg_view
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT l.namefirst, l.namelast, l.lslg
  FROM lslg_view as l, 
  		(SELECT * FROM lslg_view WHERE playerid='mayswi01') as l2
  WHERE l.lslg>l2.lslg
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg, stddev)
AS
  SELECT yearid, MIN(salary), MAX(salary), AVG(salary), STDDEV(salary)
  FROM salaries
  GROUP BY yearid
  ORDER BY yearid ASC
;

-- Question 4ii
CREATE VIEW binid_view(binid)
AS 
	SELECT GENERATE_SERIES(0,9) AS binid
;

CREATE VIEW q4ii(binid, low, high, count)
AS
	SELECT binid, low, high, COUNT(s.salary) AS count
	FROM binid_view, salaries AS s, 
		(SELECT min+((max-min)/10)*binid FROM q4i, binid_view WHERE q4i.yearid=2016) AS low, 
		(SELECT min+((max-min)/10)*(1+binid) FROM q4i, binid_view WHERE q4i.yearid=2016) AS high
	WHERE s.yearid=2016 AND low <= s.salary AND s.salary<high AND (low-min)/((max-min)/10)=binid
	GROUP BY binid, low, high
	ORDER BY binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT s2.yearid, MIN(s1.salary-s2.salary), MAX(s1.salary-s2.salary), AVG(s1.salary-s2.salary)
  FROM salaries as s1, salaries as s2
  WHERE s2.yearid-s1.yearid=1
  GROUP BY s2.yearid
  ORDER BY s2.yearid ASC
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT s.playerid, p.namefirst, p.namelast, salary, s.yearid
  FROM salaries as s, people as p
  WHERE s.playerid=p.playerid AND (yearid=2000 OR yearid=2001) 
  		AND s.salary = ALL
  		(SELECT salary
  		FROM salaries
  		WHERE yearid=2000 OR yearid=2001)
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT a.teamid, MAX(s.salary)-MIN(s1.salary)
  FROM allstarfull as a, salaries as s, salaries as s1
  WHERE a.teamid=s.teamid AND s.teamid=s1.teamid
  GROUP BY a.teamid
  ORDER BY a.teamid 
;




















