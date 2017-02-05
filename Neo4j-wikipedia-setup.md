
After setting up wikipedia in mysql (as explained in https://github.com/hemanthsagarb/wikidump-setup/blob/master/README.md), get the csv files as follows:-

- select page_id, page_title from page where page_namespace=0 into  outfile '/tmp/page.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'   LINES TERMINATED BY '\n';

- select page_id, page_title from page where page_namespace=14 into outfile '/tmp/cats.csv'FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n';

- select rd_from, page_id from redirect, page where  rd_title=page_title and rd_namespace = page_namespace and  rd_namespace=0 into outfile '/tmp/redirects.csv'

- select cl_from, a.page_id from categorylinks, page a, page b where cl_to = a.page_title and a.page_namespace=14 and b.page_id = cl_from and b.page_namespace=0 and b.page_is_redirect=0 into outfile '/tmp/catlinks_articles.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n';

- select cl_from, a.page_id from categorylinks, page a, page b where cl_to = a.page_title and a.page_namespace=14 and b.page_id = cl_from and b.page_namespace=14 and b.page_is_redirect=0 into outfile '/tmp/subcats.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n';

## Loading the files in Neo4j browser

using periodic commit
LOAD CSV FROM "file:///page.csv" AS line 
Create (m:Article{wiki_id:toInt(line[0]), title: line[1]})  

create index on :Article(wiki_id)

create index on :Article(title)

using periodic commit
LOAD CSV FROM "file:///cats.csv" AS line 
Create (m:Category{wiki_id:toInt(line[0]), title: line[1]})  

create index on :Category(wiki_id)

create index on :Category(title)

using periodic commit
LOAD CSV FROM "file:///redirects.csv" AS line 
Match (n:Article{wiki_id:toInt(line[0])})  
Match (m:Article{wiki_id:toInt(line[1])})
Create (n)-[:REDIRECT]-(m)

using periodic commit
LOAD CSV FROM "file:///catlinks_articles.csv" AS line 
Match (n:Article{wiki_id:toInt(line[0])})  
Match (m:Category{wiki_id:toInt(line[1])})
Create (n)-[:CAT]-(m)

using periodic commit
LOAD CSV FROM "file:///subcats.csv" AS line 
Match (n:Category{wiki_id:toInt(line[0])})  
Match (m:Category{wiki_id:toInt(line[1])})
Create (n)-[:CAT]-(m)
