 create index idx_page_id on page(page_id);
 create index idx_page_title_ns on page(page_title,page_namespace);
 create index idx_rd_from on redirect(rd_from);
 create index idx_rd_title_ns on redirect(rd_title, rd_namespace);
 create index idx_clinks_from on categorylinks(cl_from);
 create index idx_clinks_to on categorylinks(cl_to);
 
