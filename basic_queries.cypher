MATCH ( node ) RETURN node;


MATCH ( node ) RETURN DISTINCT labels(node);


MATCH ()-[ relationship ]-() RETURN DISTINCT 
type(relationship), labels(startNode(relationship)), labels(endNode(relationship));


MATCH ( user:User ) RETURN user;


MATCH ( show:Show ) RETURN show;


MATCH ( category:Category ) RETURN category;


MATCH ( :User { name: "Leonardo" } )-[ :WATCH ]->( show:Show )-[ :HAS_CATEGORY ]->( category:Category )
RETURN show.name, collect(category.name);

