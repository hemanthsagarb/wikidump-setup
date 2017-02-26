# wikidump-setup

##How to setup wikipedia data in mysql and Neo4j

Get the latest dumps from wikimedia site and Unzip each of the above files

- wget https://dumps.wikimedia.org/enwiki/latest/enwiki-latest-redirect.sql.gz
- wget https://dumps.wikimedia.org/enwiki/latest/enwiki-latest-page.sql.gz
- wget https://dumps.wikimedia.org/enwiki/latest/enwiki-latest-categorylinks.sql.gz
- wget https://dumps.wikimedia.org/enwiki/latest/enwiki-latest-pagelinks.sql.gz

Each of the above files have sql code for creating respective tables and also data to be inserted. The tables are created using indexes which makes it very slow for the entire data to load often taking upto 1 day.

Instead of this, we can create tables without indexes, load the data and then create the indexes after the load has finished.

**$grep -n "Dumping data" enwiki-latest-redirect.sql**

37:-- Dumping data for table `redirect`

This command returns the line number that separates the table creation part and actual data part. Here it is '37'. Using this number create the following two files.

**head -37 enwiki-latest-redirect.sql > redirect-creation.sql**

**tail -n +37 enwiki-latest-redirect.sql > redirect-data.sql**

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

**CREATE TABLE `redirect` (
  `rd_from` int(8) unsigned NOT NULL DEFAULT '0',
  `rd_namespace` int(11) NOT NULL DEFAULT '0',
  `rd_title` varbinary(255) NOT NULL DEFAULT '',
  `rd_interwiki` varbinary(32) DEFAULT NULL,
  `rd_fragment` varbinary(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=binary;**

The table creation codes are available for page, pagelinks, categorylinks and redirect. 

The same process can be followed for other dumps as well.


**mysql -uroot database_name < redirect-creation.sql**

**mysql -uroot database_name < redirect-data.sql**

Once all the files are loaded we can add indexes to the required columns. For the redirect table, we can create indexes as follows:-
 - create index idx_rd_from on redirect(rd_from);
 - create index idx_rd_title_ns on redirect(rd_title, rd_namespace);

Indexes for other tables can be found in indexes.sql
 
Add column to page table so that titles can be searched using lower case (mRNA -> mrna, Usa -> usa) using following sql commands:

- alter table page add column norm_title varbinary(255);

- update page set norm_title = LOWER(CONVERT(BINARY page_title USING UTF8));

- create index idx_norm_title on page(norm_title);

### Processing raw wikidumps and mining data

#### Wikilinks
Wikilinks are of the form [[United_States_dollar|$]]. The right side of the pipe is what appears as part of text and when we click on it, it takes to the wiki article on the left side of the pipe. More about wikilinks can be found here (https://en.wikipedia.org/wiki/Help:Link).


We process the dump and collect the counts of cooccurences of such pairs. 

The code to process the dump and analyze the wikilinks can be found in:-
https://github.com/hemanthsagarb/wikify/blob/master/src/main/java/corpus_generation/WikilinkAnalyzer.java
This takes about 6 hrs to run on Macbook pro 2.5 GHz Intel Core i7.

When we run the above, it will write a csv file which looks like this

- "apple_ipad","Apple_iPad","IPad","MAIN_ARTICLE","51"
- "apple_imac","Apple_iMac","IMac","MAIN_ARTICLE","3"
- "rna","RNA","Non-coding_RNA","MAIN_ARTICLE","157"
- "rna","RNA","RNA_virus","MAIN_ARTICLE","8"

This data can be used to calculate what a phrase/word can mean as per wikipedia. For example, the word 'apple' can mean Apple, Apple_Inc., Apple_Records, etc. In other words, it gives the most prominent senses (if we order by cooccurence counts) for a given word or phrase.



