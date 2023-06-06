// Content-Based Filtering


MATCH          ( user:User { name: "Angela Thompson" } )-[ rated:RATED ]->( :Movie )
WHERE            rated.rating >= 3.0
 WITH DISTINCT   rated.rating AS high_rating, user
MATCH          ( user )-[ :RATED { rating: high_rating } ]->( movie_1:Movie )
      ,        ( movie_1 ) -[ :IN_GENRE ]->( :Genre )<-[ :IN_GENRE ]- ( movie_2:Movie )
      ,        ( movie_1 )<-[ :ACTED_IN ]- ( :Actor ) -[ :ACTED_IN ]->( movie_2       )
WHERE NOT      ( user )-[ :RATED                         ]->( movie_2       )
 WITH            movie_1, movie_2
MATCH          ( actor_1:Actor )-[ :ACTED_IN ]->( movie_1 )-[ :IN_GENRE ]->( genre_1:Genre )
MATCH          ( actor_2:Actor )-[ :ACTED_IN ]->( movie_2 )-[ :IN_GENRE ]->( genre_2:Genre )
 WITH            movie_1, movie_2
      ,          collect(DISTINCT genre_1.name) AS genres_1
      ,          collect(DISTINCT genre_2.name) AS genres_2
      ,          collect(DISTINCT actor_1.name) AS actors_1 
      ,          collect(DISTINCT actor_2.name) AS actors_2
      ,          collect(DISTINCT id(genre_1))  AS set_1
      ,          collect(DISTINCT id(genre_2))  AS set_2
      ,          collect(DISTINCT id(actor_1))  AS set_3 
      ,          collect(DISTINCT id(actor_2))  AS set_4  
RETURN           movie_1.title AS `TOP RATED MOVIE`
      ,          movie_2.title AS `UNWATCHED MOVIE`
      ,          genres_1 AS `1st MOVIE GENRES` 
      ,          genres_2 AS `2nd MOVIE GENRES`
      ,          actors_1 AS `1st MOVIE ACTORS`
      ,          actors_2 AS `2nd MOVIE ACTORS`
      ,          gds.similarity.jaccard(set_1, set_2) AS `RECOMMENDATION POINTS BASED ON GENRES USING JACCARD`
      ,          gds.similarity.overlap(set_3, set_4) AS `RECOMMENDATION POINTS BASED ON ACTORS USING OVERLAP`
ORDER BY         movie_1.title ASC
      ,         `RECOMMENDATION POINTS BASED ON GENRES USING JACCARD` DESC
      ,         `RECOMMENDATION POINTS BASED ON ACTORS USING OVERLAP` DESC;


// Collaborative Filtering


MATCH     ( user_1:User { name: "Angela Thompson" } )-[ rated_1:RATED ]->
          ( movie:Movie )<-[ rated_2:RATED ]-( user_2:User )
WHERE       user_1 <> user_2
 WITH       user_1 ,  user_2
      ,     collect(rated_1.rating) AS vector_1
      ,     collect(rated_2.rating) AS vector_2
      ,     collect({ movie_title  : movie.title
                    , user_1_rating: rated_1.rating
                    , user_2_rating: rated_2.rating }) AS ratings
RETURN      user_1.name AS `1st USER`
      ,     user_2.name AS `2nd USER`
      ,     ratings     AS `RATING`
      ,     gds.similarity.pearson(vector_1, vector_2) AS `SIMILARITY POINTS`
                                                 ORDER BY `SIMILARITY POINTS` DESC;


MATCH     ( user_1:User { name: "Angela Thompson" } )-[ rated_1:RATED ]->
          ( :Movie )<-[ rated_2:RATED ]-( user_2:User )
WHERE       user_1 <> user_2
 WITH       user_1 ,  user_2
      ,     collect(rated_1.rating) AS vector_1
      ,     collect(rated_2.rating) AS vector_2
 WITH       user_1 ,  user_2
      ,     gds.similarity.pearson(vector_1, vector_2) AS similarity_points
WHERE       similarity_points >= 0.5
MATCH     ( user_2 )-[ rated:RATED ]->( movie:Movie )
WHERE NOT ( user_1 )-[      :RATED ]->( movie       )
      AND   rated.rating >= 3.0
 WITH       movie
      ,     collect({ `HIS/HER NAME`  : user_2.name
                    , `HIS/HER RATING`: rated.rating }) AS ratings
WHERE       size(ratings) >= 30
RETURN      movie.title AS `RECOMMENDED MOVIE`
      ,     ratings     AS `PEOPLE SAME AS YOU ALSO RATED`
ORDER BY    movie.title ASC;

