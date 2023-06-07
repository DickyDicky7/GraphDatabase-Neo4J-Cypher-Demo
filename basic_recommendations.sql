-- NOTE: THESE CODES ARE NOT REAL. THE PURPOSE OF THESE IS TO SHOW THE 'EQUIVALENT STRUCTURE' OF THE CYPHER QUERIES IN SQL.


-- Content-Based Filtering


WITH
    high_rated_movies
    AS
    (
        SELECT
            m.movie_id,
            m.title AS "TOP RATED MOVIE"
        FROM
            users u
            JOIN ratings r ON u.user_id = r.user_id
            JOIN movies m ON r.movie_id = m.movie_id
        WHERE
    u.name = 'Angela Thompson' AND r.rating >= 3.0
    ),
    recommended_movies
    AS
    (
        SELECT
            m1.title AS "TOP RATED MOVIE",
            m2.title AS "UNWATCHED MOVIE",
            ARRAY_AGG(DISTINCT g1.name) AS "1st MOVIE GENRES",
            ARRAY_AGG(DISTINCT g2.name) AS "2nd MOVIE GENRES",
            ARRAY_AGG(DISTINCT a1.name) AS "1st MOVIE ACTORS",
            ARRAY_AGG(DISTINCT a2.name) AS "2nd MOVIE ACTORS",
            similarity.jaccard(ARRAY_AGG(DISTINCT g1.genre_id), ARRAY_AGG(DISTINCT g2.genre_id)) AS "RECOMMENDATION POINTS BASED ON GENRES USING JACCARD",
            similarity.overlap(ARRAY_AGG(DISTINCT a1.actor_id), ARRAY_AGG(DISTINCT a2.actor_id)) AS "RECOMMENDATION POINTS BASED ON ACTORS USING OVERLAP"
        FROM
            high_rated_movies hrm
            JOIN ratings r1 ON hrm.movie_id = r1.movie_id
            JOIN users u ON r1.user_id = u.user_id
            JOIN ratings r2 ON u.user_id = r2.user_id
            JOIN movies m1 ON r1.movie_id = m1.movie_id
            JOIN movies m2 ON r2.movie_id = m2.movie_id
            JOIN movie_genre mg1 ON m1.movie_id = mg1.movie_id
            JOIN movie_genre mg2 ON m2.movie_id = mg2.movie_id
            JOIN genres g1 ON mg1.genre_id = g1.genre_id
            JOIN genres g2 ON mg2.genre_id = g2.genre_id
            JOIN movie_actor ma1 ON m1.movie_id = ma1.movie_id
            JOIN movie_actor ma2 ON m2.movie_id = ma2.movie_id
            JOIN actors a1 ON ma1.actor_id = a1.actor_id
            JOIN actors a2 ON ma2.actor_id = a2.actor_id
        WHERE
    NOT EXISTS (
      SELECT 1
        FROM ratings r
        WHERE u.user_id = r.user_id AND m2.movie_id = r.movie_id
    )
        GROUP BY
    m1.title, m2.title
    )
SELECT
    "TOP RATED MOVIE",
    "UNWATCHED MOVIE",
    "1st MOVIE GENRES",
    "2nd MOVIE GENRES",
    "1st MOVIE ACTORS",
    "2nd MOVIE ACTORS",
    "RECOMMENDATION POINTS BASED ON GENRES USING JACCARD",
    "RECOMMENDATION POINTS BASED ON ACTORS USING OVERLAP"
FROM
    recommended_movies
ORDER BY
  "TOP RATED MOVIE" ASC,
  "RECOMMENDATION POINTS BASED ON GENRES USING JACCARD" DESC,
  "RECOMMENDATION POINTS BASED ON ACTORS USING OVERLAP" DESC;


-- Collaborative Filtering


SELECT
    u1.name AS "1st USER",
    u2.name AS "2nd USER",
    array_agg(
    JSON_BUILD_OBJECT(
      'movie_title', m.title,
      'user_1_rating', r1.rating,
      'user_2_rating', r2.rating
    )
  ) AS "RATING",
    corr(r1.rating, r2.rating) AS "SIMILARITY POINTS"
FROM
    users u1
    JOIN ratings r1 ON u1.user_id = r1.user_id
    JOIN movies m ON r1.movie_id = m.movie_id
    JOIN ratings r2 ON r1.movie_id = r2.movie_id
    JOIN users u2 ON r2.user_id = u2.user_id
WHERE
  u1.name = 'Angela Thompson' AND u1.name <> u2.name
GROUP BY
  u1.name, u2.name
ORDER BY
  "SIMILARITY POINTS" DESC;


WITH
    vector_1
    AS
    (
        SELECT
            r1.rating
        FROM
            users u1
            JOIN ratings r1 ON u1.user_id = r1.user_id
        WHERE
    u1.name = 'Angela Thompson'
    ),
    similar_users
    AS
    (
        SELECT
            u2.user_id
        FROM
            users u1
            JOIN ratings r1 ON u1.user_id = r1.user_id
            JOIN movies m ON r1.movie_id = m.movie_id
            JOIN ratings r2 ON r1.movie_id = r2.movie_id
            JOIN users u2 ON r2.user_id = u2.user_id
        WHERE
    u1.name = 'Angela Thompson' AND u1.name <> u2.name
        GROUP BY
    u2.user_id
        HAVING
    corr(vector_1.rating, r2.rating) >= 0.5
    ),
    recommended_movies
    AS
    (
        SELECT
            m.title AS "RECOMMENDED MOVIE",
            u2.name AS "HIS/HER NAME",
            r.rating AS "HIS/HER RATING"
        FROM
            similar_users su
            JOIN ratings r ON su.user_id = r.user_id
            JOIN movies  m ON r.movie_id = m.movie_id
            JOIN users  u2 ON r.user_id  = u2.user_id
        WHERE
    NOT EXISTS (
      SELECT 1
            FROM ratings r1
            WHERE  u1.user_id = r1.user_id AND m.movie_id = r1.movie_id
    )
            AND r.rating >= 3.0
        GROUP BY
    m.title, u2.name, r.rating
        HAVING
    COUNT(*) >= 30
    )
SELECT
    "RECOMMENDED MOVIE",
    ARRAY_AGG(JSON_BUILD_OBJECT("HIS/HER NAME", "HIS/HER RATING")) AS "PEOPLE SAME AS YOU ALSO RATED"
FROM
    recommended_movies
GROUP BY
  "RECOMMENDED MOVIE"
ORDER BY
  "RECOMMENDED MOVIE" ASC;

