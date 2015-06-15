# AssignCompanySegmentsPostgreSQL.R
# after: AssignCompanySegments.R
# this version:
# 1) Sources survey flags from PostgreSQL table customers
# 2) Returns segment to segment_type which is enumerated:
#     ('Enterprise', 'Freemium', 'Marketplaces', 'Ads/Leadgen', 'Ecommerce', 'SAAS', 'empty')


# added by Rayo in order to get database access parameters as arguments to this script
args <- commandArgs(TRUE)
for(i in 1:length(args)){
  eval(parse(text=args[[i]]))
}
# we care for the following arguments:  db_hostname, db_username, db_password, db_database, db_port


# Prototype production code

######
# Setup
###

library(flexclust)
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, user=db_username, password=db_password, dbname=db_database, host=db_hostname, port=db_port)
if(!exists("con")) stop("Could not connect to PostgreSQL")

load("kcca_7_6_18_20140916_v1d.Rda")    ## latest 7 question, 6 segment model

# pick up column names from kcca object
ColumnNames <- dimnames(kcca_7_6_18@centers)[[2]]

# segment names corresponding to segment numbers 1:6 in kcca object (NTS: model builder should insert into kcca object!)
seg_names <- c("Enterprise", "Freemium", "Marketplaces", "Ads/Leadgen", "Ecommerce", "SAAS")

######
# Get rows from companies with "empty" segment_type
###
# Selecting all columns that we need for segmentation PLUS id column (for rownames, see below)

query = sprintf("SELECT id, monetiz_direct_standard, monetiz_direct_freemium, monetiz_indirect_standard, monetiz_indirect_two_sided, user_consumer, user_sme, user_enterprise, user_other, payer_consumer, payer_sme, payer_enterprise, payer_other, conv_visitor_user, conv_visitor_lead, conv_visitor_payer, conv_user_payer, conv_lead_payer, conv_other, life_day, life_week, life_month, life_quarter, life_year, life_two_years, life_three_years, life_four_years, life_five_years, life_more_five_years, acqu_affiliate, acqu_app_store, acqu_biz_dev, acqu_blogs, acqu_campaigns, acqu_conferences, acqu_direct_sales, acqu_domains, acqu_email, acqu_pr, acqu_radio, acqu_sem, acqu_seo, acqu_social_media, acqu_sponsorship, acqu_telemarketing, acqu_tv, acqu_viral_referral, acqu_widgets, acqu_word_of_mouth, acqu_other, rev_advertising, rev_consulting, rev_data, rev_hardware, rev_lead_generation, rev_license, rev_listing, rev_ownership, rev_rental, rev_sponsorship, rev_subscription, rev_transaction, rev_unit_selling, rev_virtual_goods FROM companies WHERE segment_type IS NULL OR id=%s", company_id)

scs0 <- dbGetQuery(con, query)    # ='empty'
# Removing id-column for matrix that is used for clustering
scs <- subset(scs0, select = -c(id))
# Field id is used as identifier for row(name)s
rownames(scs) <- scs0$id
# companies table does not have user_ and payer_ columns, we need to add those
scs$user_ <- with(scs, !(user_consumer | user_sme | user_enterprise | user_other))
scs$payer_ <- with(scs, !(payer_consumer | payer_sme | payer_enterprise | payer_other))

segments <- try({
  cluster <- data.frame(cluster_num = predict(kcca_7_6_18, scs))
  cluster$id <- as.integer(rownames(scs))
  cluster$segment <- seg_names[cluster$cluster_num]
  cluster[c(2, 1, 3)]
}, silent=TRUE
)

if(dbExistsTable(con, "temp_segments")) dbRemoveTable(con, "temp_segments")
dbWriteTable(con, "temp_segments", segments)

qUpdate <- paste(
  "UPDATE companies AS c",
     "SET segment_type = CAST(s.segment AS company_segment)",
    "FROM temp_segments AS s",
   "WHERE c.id = s.id"
 )
dbSendQuery(con, qUpdate)


# clean house:
dbRemoveTable(con, "temp_segments")
postgresqlCloseConnection(con)
# postgresqlCloseDriver(drv)       ## why does this throw error?

### NTS: wrap above in try(), make all into a function?


