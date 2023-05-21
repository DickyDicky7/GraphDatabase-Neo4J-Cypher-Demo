LOAD CSV FROM
"https://raw.githubusercontent.com/DickyDicky7/GraphDatabase-Neo4J-Cypher-Demo/main/shows.csv" AS row
WITH 
row, toInteger(row[0]) AS id, row[1] AS labels, row[2] AS follows, row[3] AS name, row[4] AS surname, toInteger(row[5]) AS start, toInteger(row[6]) AS end, row[7] AS type, toFloat(row[8]) AS rating
WHERE labels IS NOT NULL
CALL apoc.do.case
(
    [
        labels = ":User"    , "CREATE ( user    :User     { id: $id, name: $name, surname: $surname } ) RETURN user    "
    ,   labels = ":Show"    , "CREATE ( show    :Show     { id: $id, name: $name, follows: $follows } ) RETURN show    "
    ,   labels = ":Category", "CREATE ( category:Category { id: $id, name: $name                    } ) RETURN category"
    ]
    ,                         "                                                                         RETURN null    "
    ,   { id: id, name: name, surname: surname, follows: follows }
)
YIELD value RETURN value;
