###############################
#name: Figures 1-3_CS.R
#description: Event-Study Analyses of RMLs and Race-Specific Arrests, 
#             Callaway and Sant’Anna (2021) Estimates
###############################
#install.packages("readstata13")
library(readstata13)
#install.packages("did")
library(did)

#load analysis data
rml_white <- read.dta13("C:/Users/Zachary.Fone/Dropbox/RESEARCH/RML project/empirical/source_data/data/analysis_files/rml_white.dta")
rml_black <- read.dta13("C:/Users/Zachary.Fone/Dropbox/RESEARCH/RML project/empirical/source_data/data/analysis_files/rml_black.dta")

#set your directory
setwd("C:/Users/Zachary.Fone/Dropbox/RESEARCH/RML project/empirical/analysis/figures/from R/")

# NOTE:
#   
# Defer to use of "allow_unbalanced_panel = FALSE"
# 
# Why?
#   1) Yields different results even if the data are strongly balanced (i.e., when 
#      setting = "TRUE" or "FALSE"), but you employ weights OR covariates 
#   2) "did" maintainers do not appear to have a good handle on why this is the case. 
#      Possibly may be due to "did" using repeated cross section estimation when 
#      using "allow_unbalanced_panel = FALSE", but I don't know. For github issues 
#      threads on this, see:
#         https://github.com/bcallaway11/did/issues/76
#         https://github.com/bcallaway11/did/issues/90
#         https://github.com/bcallaway11/did/discussions/110
# 
#     Related, an interesting discussion on time-varying covariates:
#       https://github.com/bcallaway11/did/discussions/111


#### Black ####

## Total arrest categories ####
x<-c("rate_total_cannabis_1899", "rate_total_heroin_coke_1899", "rate_total_synth_narc_1899",
     "rate_total_other_drug_1899", "rate_total_property_1899", "rate_total_violent_1899")

for (y in x) {
  
  set.seed(8675309)
  attgt <- att_gt(yname = y,
                  gname = "g_rml",
                  idname = "fips",
                  tname = "year",
                  weightsname = "pop_1899",
                  control_group = "nevertreated",
                  xformla = ~ mml + decrim + unemployment + lnpci + num_agencies_report,
                  panel = TRUE,
                  allow_unbalanced_panel = FALSE,
                  bstrap = TRUE,
                  biters = 1000, 
                  clustervars = "fips", 
                  est_method = "reg",
                  base_period = "universal",
                  data = rml_black
  )
  
  # aggregate the group-time average treatment effects into event study estimates
  set.seed(8675309)
  attgt_dyn <- aggte(attgt, type = "dynamic", na.rm = TRUE)
  summary(attgt_dyn)
  ggdid(attgt_dyn)
  
  #save output as .csv
  #dynamic
  dyn_t<-tidy(attgt_dyn)
  dyn_g<-glance(attgt_dyn)
  dyn<-merge(dyn_t, dyn_g, by = "type")
  dyn$group=NA
  dyn$outcome=y
  dyn$point_crit=(dyn$estimate-dyn$point.conf.low)/dyn$std.error #pointwise 95% CI critical value
  dyn$simult_crit=(dyn$estimate-dyn$conf.low)/dyn$std.error #simultaneous 95% CI critical value
  write.csv(dyn, paste(y, "_black.csv"))
  
  rm(attgt, attgt_dyn, dyn, dyn_g, dyn_t)
  
}

## Marijuana possession/sales arrest categories ####
x<-c("rate_poss_cannabis_1899", "rate_sale_cannabis_1899")

for (y in x) {
  
  set.seed(8675309)
  attgt <- att_gt(yname = y,
                  gname = "g_rml",
                  idname = "fips",
                  tname = "year",
                  weightsname = "pop_1899",
                  control_group = "nevertreated",
                  xformla = ~ mml + decrim + unemployment + lnpci + num_agencies_report,
                  panel = TRUE,
                  allow_unbalanced_panel = FALSE,
                  bstrap = TRUE,
                  biters = 1000, 
                  clustervars = "fips", 
                  est_method = "reg",
                  base_period = "universal",
                  data = rml_black
  )
  
  # aggregate the group-time average treatment effects into event study estimates
  set.seed(8675309)
  attgt_dyn <- aggte(attgt, type = "dynamic", na.rm = TRUE)
  summary(attgt_dyn)
  ggdid(attgt_dyn)
  
  #save output as .csv
  #dynamic
  dyn_t<-tidy(attgt_dyn)
  dyn_g<-glance(attgt_dyn)
  dyn<-merge(dyn_t, dyn_g, by = "type")
  dyn$group=NA
  dyn$outcome=y
  dyn$point_crit=(dyn$estimate-dyn$point.conf.low)/dyn$std.error #pointwise 95% CI critical value
  dyn$simult_crit=(dyn$estimate-dyn$conf.low)/dyn$std.error #simultaneous 95% CI critical value
  write.csv(dyn, paste(y, "_black.csv"))
  
  rm(attgt, attgt_dyn, dyn, dyn_g, dyn_t)
  
}

#### White ####

## Total arrest categories ####
x<-c("rate_total_cannabis_1899", "rate_total_heroin_coke_1899", "rate_total_synth_narc_1899",
     "rate_total_other_drug_1899", "rate_total_property_1899", "rate_total_violent_1899")

for (y in x) {
  
  set.seed(8675309)
  attgt <- att_gt(yname = y,
                  gname = "g_rml",
                  idname = "fips",
                  tname = "year",
                  weightsname = "pop_1899",
                  control_group = "nevertreated",
                  xformla = ~ mml + decrim + unemployment + lnpci + num_agencies_report,
                  panel = TRUE,
                  allow_unbalanced_panel = FALSE,
                  bstrap = TRUE,
                  biters = 1000, 
                  clustervars = "fips", 
                  est_method = "reg",
                  base_period = "universal",
                  data = rml_white
  )
  
  # aggregate the group-time average treatment effects into event study estimates
  set.seed(8675309)
  attgt_dyn <- aggte(attgt, type = "dynamic", na.rm = TRUE)
  summary(attgt_dyn)
  ggdid(attgt_dyn)
  
  #save output as .csv
  #dynamic
  dyn_t<-tidy(attgt_dyn)
  dyn_g<-glance(attgt_dyn)
  dyn<-merge(dyn_t, dyn_g, by = "type")
  dyn$group=NA
  dyn$outcome=y
  dyn$point_crit=(dyn$estimate-dyn$point.conf.low)/dyn$std.error #pointwise 95% CI critical value
  dyn$simult_crit=(dyn$estimate-dyn$conf.low)/dyn$std.error #simultaneous 95% CI critical value
  write.csv(dyn, paste(y, "_white.csv"))
  
  rm(attgt, attgt_dyn, dyn, dyn_g, dyn_t)
  
}

## Marijuana possession/sales arrest categories ####
x<-c("rate_poss_cannabis_1899", "rate_sale_cannabis_1899")

for (y in x) {
  
  set.seed(8675309)
  attgt <- att_gt(yname = y,
                  gname = "g_rml",
                  idname = "fips",
                  tname = "year",
                  weightsname = "pop_1899",
                  control_group = "nevertreated",
                  xformla = ~ mml + decrim + unemployment + lnpci + num_agencies_report,
                  panel = TRUE,
                  allow_unbalanced_panel = FALSE,
                  bstrap = TRUE,
                  biters = 1000, 
                  clustervars = "fips", 
                  est_method = "reg",
                  base_period = "universal",
                  data = rml_white
  )
  
  # aggregate the group-time average treatment effects into event study estimates
  set.seed(8675309)
  attgt_dyn <- aggte(attgt, type = "dynamic", na.rm = TRUE)
  summary(attgt_dyn)
  ggdid(attgt_dyn)
  
  #save output as .csv
  #dynamic
  dyn_t<-tidy(attgt_dyn)
  dyn_g<-glance(attgt_dyn)
  dyn<-merge(dyn_t, dyn_g, by = "type")
  dyn$group=NA
  dyn$outcome=y
  dyn$point_crit=(dyn$estimate-dyn$point.conf.low)/dyn$std.error #pointwise 95% CI critical value
  dyn$simult_crit=(dyn$estimate-dyn$conf.low)/dyn$std.error #simultaneous 95% CI critical value
  write.csv(dyn, paste(y, "_white.csv"))
  
  rm(attgt, attgt_dyn, dyn, dyn_g, dyn_t)
  
}


