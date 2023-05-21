LOAD CSV FROM
"https://raw.githubusercontent.com/DickyDicky7/GraphDatabase-Neo4J-Cypher-Demo/main/shows.csv" AS row
WITH 
row, toInteger(row[0]) as id, row[1] as labels, row[2] as follows, row[3] as name, row[4] as surname, toInteger(row[5]) as start, toInteger(row[6]) as end, row[7] as type, toFloat(row[8]) as rating
WHERE type IS NOT NULL
CALL apoc.do.case
(
    [
        type = "WATCH"       , "MATCH ( user:User { id: $startId } )
                                MATCH ( show:Show { id: $endId   } ) 
                               CREATE (user)-[ watch:WATCH { rating: $rating } ]->(show)
                               RETURN watch
                               "

    ,   type = "HAS_CATEGORY", "MATCH ( show    :Show     { id: $startId } )
                                MATCH ( category:Category { id: $endId   } )
                               CREATE (show)-[ has_category:HAS_CATEGORY ]->(category)
                               RETURN has_category
                               "
    ]
    ,                          "
                               RETURN null
                               "
    ,   { startId: start, endId: end, rating: rating }
)
YIELD value RETURN value;
