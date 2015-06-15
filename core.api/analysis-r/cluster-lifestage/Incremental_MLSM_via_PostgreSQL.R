# Incremental_MLSM_via_PostgreSQL.R
# after: Incremental_MLSM.R
# runs randomForest predict on new companies to get Modeled_LSM & Rank_LSM values
# TODO: wrap sections in try()'s to trap errors  


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

library(randomForest)
library(dplyr)
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, user=db_username, password=db_password, dbname=db_database, host=db_hostname, port=db_port)
if(!exists("con")) stop("Could not connect to PostgreSQL")

load("RF_ModeledLSM_models.Rda")  # the list of models
LSM_SegmentModels$Meta            # if testing, look at meta data for models 

# segment names corresponding to segment numbers 1:6 in kcca object (NTS: model builder should insert into kcca object!)
seg_names <- c("Ads/Leadgen", "Ecommerce", "Enterprise", "Freemium", "Marketplaces", "SAAS")

######
# Set-up LSM predictor variables for new companies - ASSUMED TO BE CLEANED AND TRANSFORMED! (NS's OK)
###

# was: ForLSM <- read.delim("NewCompanies.txt", na.strings="", colClasses=c(company_id="character", SurveyAt="POSIXct"))

# Get rows from lifestages table which have not yet been processed
ls0 <- dbGetQuery(con, "SELECT c.segment_type as segment, l.id,l.company_id,l.created_at,l.revenue_last_month,l.payers,l.users,l.employees,l.expenses_last_month,l.customer_lifetime,l.engineers  FROM lifestages l  LEFT JOIN companies c ON (l.company_id = c.id)  WHERE l.modeled_lifestage IS NULL;")
#ls0 <- dbGetQuery(con, "SELECT l.id, l.company_id, c.segment_type as segment,l.created_at,l.revenue_last_month,l.payers,l.users,l.employees,l.expenses_last_month,l.customer_lifetime,l.engineers  FROM lifestages l  LEFT JOIN companies c ON (l.company_id = c.id)  WHERE l.modeled_lifestage IS NULL;")
#ls0 <- dbGetQuery(con, "SELECT * FROM lifestages l WHERE l.modeled_lifestage IS NULL;")

# map postgres columns back to R columns used to build model
ForLSM <- ls0 %>%
  select(table_id                        = id,
         company_id,
         SurveyAt                        = created_at,
         Segment                         = segment,
         REVENUE_MONTH                   = revenue_last_month,
         NO_OF_PAYERS_CURRENT            = payers,
         NO_OF_USERS_CURRENT             = users,
         NO_OF_EMPLOYEES_CURRENT         = employees,
         EXPENSES_MONTH                  = expenses_last_month,
         CUSTOMER_LIFETIME_VALUE_CURRENT = customer_lifetime,
         NO_OF_ENGINEERS_CURRENT         = engineers)
# For debugging, un-comment this line:
# save(ls0, ForLSM, file="ForJim.Rda")   ## RData file for Jim

ForLSM$Segment <- factor(ForLSM$Segment, levels = seg_names)


# do log10 transform as in original data cleanup in StageClusteringEDA.R

to_log10 <- lapply(ForLSM, class) %in% c("integer", "numeric")
# to_log10 <- to_log10 & as.numeric(apply(ForLSM, 2, max, na.rm=TRUE)) > 150 ## not valid for predict!
to_log10[1:4] <- FALSE          ## identifier columns not to be transformed

ForLSM[to_log10] <- apply(ForLSM[to_log10] + 0.1, 2, log10)
colnames(ForLSM)[to_log10] <- paste0(colnames(ForLSM)[to_log10], "_log10")




## treate some NAs as zeros (which is represented as 0.1 if log10 xformed):
# ForLSM$[is.na(ForLSM$)] <- 0.1    ## pattern for below
ForLSM$REVENUE_MONTH_log10[is.na(ForLSM$REVENUE_MONTH_log10)] <- -0.1
ForLSM$NO_OF_PAYERS_CURRENT_log10[is.na(ForLSM$NO_OF_PAYERS_CURRENT_log10)] <- -0.1
ForLSM$NO_OF_USERS_CURRENT_log10[is.na(ForLSM$NO_OF_USERS_CURRENT_log10)] <- -0.1
ForLSM$EXPENSES_MONTH_log10[is.na(ForLSM$EXPENSES_MONTH_log10)] <- -0.1
ForLSM$CUSTOMER_LIFETIME_VALUE_CURRENT_log10[is.na(ForLSM$CUSTOMER_LIFETIME_VALUE_CURRENT_log10)] <- -0.1
# NTS: not doing Employees or Engineers - only one record where NA & just remove below  ???

## drop rows with any NA.  For now, try impute later
cc <- complete.cases(ForLSM)
(Number_Complete_Cases <- sum(cc))
ForLSM <- ForLSM[cc, ]

######
# Run predict.rf segment by segment
###

ModeledLSM <- data.frame(table_id = integer(0),           ## set up output data.frame
                         company_id = character(0),       
                         SurveyAt = numeric(0),           ## will become POSIXct
                         Segment = character(0),
                         modeled_lsm = numeric(0))

Segments2Proceess <- levels(droplevels(ForLSM)$Segment) ## just for segments actually in data set

for(ithSegment in Segments2Proceess) {
  Model.list <- LSM_SegmentModels[[ithSegment]]  
  Model.rf <- Model.list$rf
  Model.centers <- Model.list$center
  Model.scales <- Model.list$scale 
  
  cols2exclude <- ifelse(ithSegment == "Ads/Leadgen", "NO_OF_PAYERS_CURRENT_log10", 
                         ifelse(ithSegment %in% c("Ecommerce", "Enterprise"),
                                "NO_OF_USERS_CURRENT_log10", "xxxxx")
  )
  cols2select <- colnames(ForLSM)[!(colnames(ForLSM) %in% cols2exclude)]
  Predictors <- subset(ForLSM, Segment == ithSegment, select=cols2select)
  # apply scaling used when building model  
  Predictors.scaled <- Predictors[, -(1:4)]                 ## just actual numeric predictors to rf
  for (ithCol in seq_along(Predictors.scaled[1,])){
    Predictors.scaled[, ithCol] <- (Predictors.scaled[, ithCol] - 
                                      Model.centers[ithCol]) / Model.scales[ithCol]
  }
  Predictors$modeled_lsm <- predict(Model.rf, Predictors.scaled)
  ModeledLSM <- rbind(ModeledLSM, Predictors[, c("table_id", "company_id", "SurveyAt", 
                                                 "Segment", "modeled_lsm")])
}

######
# Update lifestages.modeled_lifestage with the predicted values
###

# was: write.table(ModeledLSM, file=fname.out, row.names=FALSE, quote=FALSE, sep="\t", na="")

if(dbExistsTable(con, "temp_mlsm")) dbRemoveTable(con, "temp_mlsm")
dbWriteTable(con, "temp_mlsm", ModeledLSM)

qUpdate <- paste(
  "UPDATE lifestages AS l",
  "SET modeled_lifestage = t.modeled_lsm",
  "FROM temp_mlsm AS t",
  "WHERE l.id = t.table_id"
)
dbSendQuery(con, qUpdate)

# clean house:
dbRemoveTable(con, "temp_mlsm")
postgresqlCloseConnection(con)
# postgresqlCloseDriver(drv)       ## why does this throw error?

### NTS: wrap above in try(), make all into a function?


