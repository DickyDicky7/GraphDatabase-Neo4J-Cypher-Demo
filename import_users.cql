LOAD CSV FROM 'file:///shows.csv' AS row
WITH row, toInteger(row[0]) as id, row[1] as labels, row[2] as follows, row[3] as name, row[4] as surname, toInteger(row[5]) as start, toInteger(row[6]) as end, row[7] as type, toFloat(row[8]) as rating
WHERE labels=":User"
CREATE (:User{id:id, name: name, surname: surname})
