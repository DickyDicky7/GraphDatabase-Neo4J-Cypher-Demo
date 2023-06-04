MATCH ( node ) RETURN node LIMIT 100;


MATCH ( node ) RETURN DISTINCT labels(node);


MATCH ()-[ relationship ]-() RETURN DISTINCT 
type(relationship), labels(startNode(relationship)), labels(endNode(relationship));


MATCH ( user:User ) RETURN user LIMIT 10;
MATCH ( actor:Actor ) RETURN actor LIMIT 10;
MATCH ( genre:Genre ) RETURN genre LIMIT 10;
MATCH ( movie:Movie ) RETURN movie LIMIT 10;


MATCH ( :User { name: "Angela Thompson" } )-[ rated:RATED ]->( movie:Movie )-[ :IN_GENRE ]->( genre:Genre )
RETURN   movie.title, rated.rating, collect(genre.name);

