// Content-Based Filtering


MATCH     ( user:User { name: "Leonardo" } )-[ :WATCH ]->
          ( show_1:Show )-[ :HAS_CATEGORY ]->( :Category )<-[ :HAS_CATEGORY ]-( show_2:Show )
WHERE NOT ( user )-[ :WATCH ]->( show_2 )
 WITH       show_1, show_2
MATCH     ( show_1 )-[ :HAS_CATEGORY ]->( category_1:Category )
MATCH     ( show_2 )-[ :HAS_CATEGORY ]->( category_2:Category )
 WITH       show_1, show_2
      ,     collect(DISTINCT category_1.name) AS categories_1
      ,     collect(DISTINCT category_2.name) AS categories_2
      ,     collect(DISTINCT category_1.id  ) AS set_1
      ,     collect(DISTINCT category_2.id  ) AS set_2
RETURN      show_1.name  AS   `WATCHED SHOW`
      ,     show_2.name  AS `UNWATCHED SHOW`
      ,     categories_1 AS  `FIRST SHOW CATEGORIES` 
      ,     categories_2 AS `SECOND SHOW CATEGORIES`
      ,     gds.similarity.jaccard(set_1, set_2) AS `RECOMMENDED POINTS`
                                           ORDER BY `RECOMMENDED POINTS` DESC;


// Collaborative-Filtering


