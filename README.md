# wikidump-setup

##How to setup wikipedia data in mysql and Neo4j

Get the latest dumps from wikimedia site and Unzip each of the above files

- wget https://dumps.wikimedia.org/enwiki/latest/enwiki-latest-redirect.sql.gz
- wget https://dumps.wikimedia.org/enwiki/latest/enwiki-latest-page.sql.gz
- wget https://dumps.wikimedia.org/enwiki/latest/enwiki-latest-categorylinks.sql.gz
- wget https://dumps.wikimedia.org/enwiki/latest/enwiki-latest-pagelinks.sql.gz

Each of the above files have sql code for creating respective tables and also data to be inserted. The tables are created using indexes which makes it very slow for the entire data to load often taking upto 1 day.

Instead of this, we can create tables without indexes, load the data and then create the indexes after the load has finished.

$grep -n "Dumping data" enwiki-latest-redirect.sql

37:-- Dumping data for table `redirect`

This command returns the line number that separates the table creation part and actual data part. Here it is '37'. Using this number create the following two files.

head -37 enwiki-latest-redirect.sql > redirect-creation.sql

tail -n +37 enwiki-latest-redirect.sql > redirect-data.sql

redirect-creation.sql has the following table creation code:-

CREATE TABLE `redirect` (
  `rd_from` int(8) unsigned NOT NULL DEFAULT '0',
  `rd_namespace` int(11) NOT NULL DEFAULT '0',
  `rd_title` varbinary(255) NOT NULL DEFAULT '',
  `rd_interwiki` varbinary(32) DEFAULT NULL,
  `rd_fragment` varbinary(255) DEFAULT NULL,
  PRIMARY KEY (`rd_from`),
  KEY `rd_ns_title` (`rd_namespace`,`rd_title`,`rd_from`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;

We remove the keys from the table creation as follows:-

CREATE TABLE `redirect` (
  `rd_from` int(8) unsigned NOT NULL DEFAULT '0',
  `rd_namespace` int(11) NOT NULL DEFAULT '0',
  `rd_title` varbinary(255) NOT NULL DEFAULT '',
  `rd_interwiki` varbinary(32) DEFAULT NULL,
  `rd_fragment` varbinary(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=binary;

The table creation codes are available for page, pagelinks, categorylinks and redirect. 

The same process can be followed for other dumps as well.


mysql -uroot database_name < redirect-creation.sql

mysql -uroot database_name < redirect-data.sql


