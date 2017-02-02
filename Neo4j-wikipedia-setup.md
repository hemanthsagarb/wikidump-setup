select page_id, page_title from page where page_namespace=0 or page_namespace=14 into  outfile '/tmp/page.csv'FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'   LINES TERMINATED BY '\n';

select rd_from, page_id from redirect, page where page_title = rd_title and rd_namespace = page_namespace and ( page_namespace=0 or page_namespace=14 ) into outfile '/tmp/redirects.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'   LINES TERMINATED BY '\n';

 select cl_from, a.page_id from page a ,page b, categorylinks where b.page_id = cl_from and a.page_title = cl_to and a.page_namespace=14 and (b.page_namespace=0  or b.page_namespace=14) and b.page_is_redirect=0 into outfile '/tmp/cats.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'   LINES TERMINATED BY '\n';
