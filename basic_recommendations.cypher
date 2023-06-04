// Content-Based Filtering
// NOTE: Angela Thompson rated Spider-Man 2

MATCH     ( user:User { name: "Angela Thompson" } )-[ :RATED ]->
          ( movie_1:Movie )-[ :IN_GENRE ]->( :Genre )<-[ :IN_GENRE ]-( movie_2:Movie )
WHERE NOT ( user )-[ :RATED ]->( movie_2 )
 WITH       movie_1, movie_2
MATCH     ( movie_1 )-[ :IN_GENRE ]->( genre_1:Genre )
MATCH     ( movie_2 )-[ :IN_GENRE ]->( genre_2:Genre )
 WITH       movie_1, movie_2
      ,     collect(DISTINCT genre_1.name) AS genres_1
      ,     collect(DISTINCT genre_2.name) AS genres_2
      ,     collect(DISTINCT id(genre_1)) AS set_1
      ,     collect(DISTINCT id(genre_2)) AS set_2
RETURN      movie_1.title AS   `WATCHED MOVIE`
      ,     movie_2.title AS `UNWATCHED MOVIE`
      ,     genres_1 AS  `FIRST MOVIE GENRES` 
      ,     genres_2 AS `SECOND MOVIE GENRES`
      ,     gds.similarity.jaccard(set_1, set_2) AS `RECOMMENDATION POINTS`
                                           ORDER BY `RECOMMENDATION POINTS` DESC;


// Collaborative Filtering


// MATCH ( user_1:User { name: "Leonardo" } )-[ watch_1:WATCH ]->( show:Show )<-[ watch_2:WATCH ]-( user_2:User )
// WHERE   user_1 <> user_2
//  WITH   user_1, user_2
//       , collect(watch_1.rating) AS vector_1
//       , collect(watch_2.rating) AS vector_2
//       , collect({ show_name: show.name
//                 , fst_user_rating: watch_1.rating
//                 , snd_user_rating: watch_2.rating }) AS ratings
// RETURN  user_1.name AS  `FIRST USER`
//       , user_2.name AS `SECOND USER`
//       , ratings     AS `RATING`
//       , gds.similarity.cosine(vector_1, vector_2) AS `SIMILARITY POINTS`
//                                             ORDER BY `SIMILARITY POINTS` DESC;



// MATCH ( user_1:User { name: "Leonardo" } )-[ watch_1:WATCH ]->( :Show )<-[ watch_2:WATCH ]-( user_2:User )
// WHERE   user_1 <> user_2
//  WITH   user_1, user_2
//       , gds.similarity.cosine(collect(watch_1.rating), collect(watch_2.rating)) AS similarity_points
//                                                                           ORDER BY similarity_points DESC
// MATCH ( user_2 )-[ watch_2:WATCH ]->( show:Show )
// WHERE NOT ( user_1 )-[ :WATCH ]->( show )
// RETURN  show.name
//       , sum(similarity_points * watch_2.rating) as score ORDER BY score DESC;av