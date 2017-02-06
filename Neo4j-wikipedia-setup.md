
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

**Wikipedia has two main categories for main articles. There are wikipedia functionality categories like "Disambiguation pages", "wikipedia redirects" which are generally hidden on the main html wikipedia page. This information is not available in the dumps. Using neo4j we can remove/tag these using the following query. Every category which do not have a path to either "Fundamental categories" or "Main topic classifications" are tagged with a property 'is_hidden' to true as follows:

using periodic commit LOAD CSV FROM "file:///tmp/cats.csv" AS line MATCH (m:Category{title:"Fundamental_categories"}) MATCH (k:Category{title:"Main_topic_classifications"}) MATCH (n:Category{title:line[1]}) set n.is_hidden = ( shortestpath((n)-[*..15]->(k)) IS NULL and shortestpath((n)-[*..15]->(k)) IS NULL);

** we can delete all the hidden categories so that they dont be a part of our graph algorithms

MATCH (n:Category{is_hidden:true}) detach delete n



## Neo4j Queries

### To get any 10 categories 

match (n:Category) return n limit 10;

![ScreenShot](https://raw.github.com/hemanthsagarb/wikidump-setup/master/images/any_10_cats.png)



### To get any 10 articles 

match (n:Article) return n limit 10;

![ScreenShot](https://raw.github.com/hemanthsagarb/wikidump-setup/master/images/any_10_articles.png)


### To see any 10 redirects

match (m)-[:RD]-> (n) return m,n limit 10;

![ScreenShot](https://raw.github.com/hemanthsagarb/wikidump-setup/master/images/any_redirects.png)


### To get top 10 Categories of a given article

match (n:Article{title:"Anarchism"})-[:CAT]->(m) return m limit 10

![ScreenShot](https://raw.github.com/hemanthsagarb/wikidump-setup/master/images/anarchism_categories.png)

