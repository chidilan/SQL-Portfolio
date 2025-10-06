USE `World Cup`;

-- 1. How many total goals are we even analyzing?
SELECT 
	COUNT(ID) AS total_goals 
FROM goals;

-- 2. Which players are the real offensive assets? List the top goal scorers.
SELECT 
	Scorer, 
    COUNT(ID) AS total_goals
FROM goals
WHERE type <> 'Own'
GROUP BY scorer
ORDER BY total_goals DESC;

-- 3. Which teams have the best offensive machine?
SELECT
	scoringteam,
    COUNT(ID) as total_goals
FROM goals
WHERE type <> 'own'
GROUP BY scoringteam
ORDER BY total_goals DESC;

-- 4. Who is letting the most goals in? This is where you find who to attack.
SELECT
	Team,
    SUM(goalsconceded) AS goals_conceded
FROM (
	SELECT
		Home AS Team,
        COUNT(*) AS goalsconceded
	FROM goals
    WHERE Home <> ScoringTeam
    GROUP BY Home
    
    UNION ALL
    
    SELECT
		Away AS Team,
        COUNT(*) AS goalsconceded
	FROM goals
    WHERE Away <> ScoringTeam
    GROUP BY Away
) t
GROUP BY Team
ORDER BY goals_conceded DESC;

-- 5. What type of goal is the highest leverage? Inside the box, freekicks, or penalties?
SELECT
	`Type`,
    count(*) AS number_of_goals,
    ROUND(100 * (COUNT(ID) / (SELECT COUNT(*) FROM goals)), 2) AS percentagegoals
FROM goals
GROUP BY `type`
ORDER BY number_of_goals DESC;

-- 6. Do teams score more when they are at home? Where's the leverage?
SELECT
	ScoringTeam,
    SUM(CASE WHEN Home = ScoringTeam THEN 1 ELSE 0 END) AS Homegoals,
    SUM(CASE WHEN Away = ScoringTeam THEN 1 ELSE 0 END) AS Awaygoals
FROM goals
GROUP BY scoringteam
ORDER BY Homegoals DESC;

-- 7. Which teams scored own goals? This is the ultimate liability
SELECT 
	CASE WHEN HOME = ScoringTeam THEN HOME ELSE AWAY END AS ConcedingTeam,
    Scorer,
    ID
FROM goals
WHERE `type` = 'Own';

-- 8. Who are the designated penalty takers and do they deliver?
SELECT
	scorer,
    scoringteam
FROM goals
WHERE `type` = 'penalty'
GROUP BY scorer, scoringteam;

-- 9. Which player has scored the highest percentage of their team's total goals? This exposes a fragile system.

WITH Teamgoals AS (
	SELECT
		ScoringTeam AS Country,
        COUNT(*) AS goalscoredbycountry
	FROM goals
    GROUP BY scoringteam
),
Playergoals AS (
	SELECT
		scorer,
		scoringteam AS Country,
		COUNT(*) AS totalgoals
FROM goals
GROUP BY scorer, scoringteam
)
SELECT
	p.Country,
	p.scorer,
    p.totalgoals,
    t.goalscoredbycountry,
    ROUND(100 * (p.totalgoals/t.goalscoredbycountry), 2) AS percentagegoals
FROM playergoals p
JOIN Teamgoals t on p.country = t.country
GROUP BY p.scorer, p.totalgoals, p.Country, t.goalscoredbycountry
ORDER BY percentagegoals DESC;

SELECT * FROM goals;

-- 10. Where was the momentum overwhelming? Identify the matches with the biggest goal difference.
SELECT
	ID,
    Home,
    Away,
    COUNT(ID) total_goals_in_match
FROM goals
GROUP BY ID, Home, Away
ORDER BY total_goals_in_match DESC;

SELECT * FROM goals;

-- 11. Do teams score more or less as the pressure mounts in later stages?
SELECT
	COUNT(ID) total_goals,
    stage,
    AVG(goalspermatch) AS Averagegoal
FROM (
	SELECT
		stage,
		ID,
		COUNT(ID) OVER (PARTITION BY ID) AS goalspermatch
	FROM goals
) AS matchgoals
GROUP BY stage;

-- 12. What's the full performance story for Russia? Goals for, goals against, and how.
SELECT
	'Goals Scored' AS Metric,
    Scorer As Detail,
    COUNT(*) AS `Count`
FROM goals
WHERE ScoringTeam = 'Russia'
GROUP BY scorer
UNION ALL
SELECT
	'Goals Conceded' AS Metric,
    ScoringTeam AS detail,
    COUNT(*) AS `Count`
FROM goals
WHERE (Home = 'Russia' OR Away = 'Russia') AND Scoringteam <> 'Russia'
Group by ScoringTeam;

-- 13. Let's isolate a key asset. How and when did Russia's top scorer, Cheryshev, make his impact?
SELECT
	ID,
    Stage,
    `type`,
    CASE WHEN Home = 'Russia' THEN Away ELSE Home END AS Opponent
FROM goals
WHERE scorer = 'Cheryshev';
    

-- 14. Which teams only score one type of goal? A predictable opponent is an easy opponent.
SELECT
	Scoringteam,
    COUNT(DISTINCT type) n_type_goals
FROM goals
GROUP BY Scoringteam
order by n_type_goals;

-- 15. What is each team's final goal difference? This is the bottom line.
SELECT
	t.team,
    COALESCE(SUM(CASE WHEN g.scoringteam = t.team THEN 1 ELSE 0 END), 0) AS goalsfor,
    COALESCE(SUM(CASE WHEN g.Home = t.team AND g.scoringteam <> t.team THEN 1
					  WHEN g.Away = t.team AND g.scoringteam <> t.team THEN 1
                      ELSE 0 END), 0) AS goalsagainst,
	(COALESCE(SUM(CASE WHEN g.scoringteam = t.team THEN 1 ELSE 0 END), 0) - COALESCE(SUM(CASE WHEN g.Home = t.team AND scoringteam <> t.team THEN 1
																										 WHEN g.away = t.team AND scoringteam <> t.team THEN 1
                                                                                                         ELSE 0 END ), 0)) AS goaldifference
FROM (
	SELECT
		Home AS Team 
	FROM goals
    UNION ALL
    SELECT
		Away AS Team 
	FROM goals
)t
LEFT JOIN goals g
ON g.home = t.team OR g.away = t.team
GROUP BY t.team;








