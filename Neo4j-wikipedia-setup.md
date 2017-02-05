
After setting up wikipedia in mysql, get the csv files as follows:-

--select page_id, page_title from page where page_namespace=0 into  outfile '/tmp/page.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'   LINES TERMINATED BY '\n';

--select page_id, page_title from page where page_namespace=14 into outfile '/tmp/cats.csv'FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n';

--select rd_from, page_id from redirect, page where  rd_title=page_title and rd_namespace = page_namespace and  rd_namespace=0 into outfile '/tmp/redirects.csv'

--select cl_from, a.page_id from categorylinks, page a, page b where cl_to = a.page_title and a.page_namespace=14 and b.page_id = cl_from and b.page_namespace=0 and b.page_is_redirect=0 into outfile '/tmp/catlinks_articles.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n';

--select cl_from, a.page_id from categorylinks, page a, page b where cl_to = a.page_title and a.page_namespace=14 and b.page_id = cl_from and b.page_namespace=14 and b.page_is_redirect=0 into outfile '/tmp/subcats.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n';
