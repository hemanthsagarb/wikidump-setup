create table wikilinks 
  ( norm varbinary(255), 
    surface_form varbinary(255),
    page_title varbinary(255),
    type varchar(20),
    count int(8)
  );

LOAD DATA INFILE 'wikilinks_analysis.csv' INTO TABLE wikilinks  FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

create index idx_wikilinks_norm on wikilinks(norm);

create index idx_wikilinks_sform on wikilinks(surface_form);


