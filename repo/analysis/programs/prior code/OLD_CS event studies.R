###############################
#CS event studies 
#
#created: october 8, 2022
#updated: october 18, 2022
###############################
#install.packages("readstata13")
library(readstata13)
#install.packages("did")
library(did)

getOption("warning.length")
options(nwarnings = 10000)

set.seed(8675309)

#load analysis data
rml_white <- read.dta13("C:/Users/Zachary.Fone/Dropbox/RESEARCH/RML project/empirical/analysis/exploratory_output/rml_white.dta")
rml_black <- read.dta13("C:/Users/Zachary.Fone/Dropbox/RESEARCH/RML project/empirical/analysis/exploratory_output/rml_black.dta")

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





################## No Covariates #######

#### Black ####

## total ####
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
                  xformla = NULL,
                  panel = TRUE,
                  allow_unbalanced_panel = FALSE,
                  bstrap = TRUE, # if TRUE compute boostrapped SE
                  biters = 1000, # number of bootstrap iterations
                  clustervars = "fips", # cluster level
                  est_method = "reg",
                  base_period = "universal",
                  data = rml_black
  )
  
  # summarize the results
  #options(max.print=999999)
  #summary(attgt)
  
  # aggregate the group-time average treatment effects into event study estimates
  set.seed(8675309)
  attgt_dyn43 <- aggte(attgt, type = "dynamic", na.rm = TRUE) #, min_e = -4, max_e = 3
  summary(attgt_dyn43)
  ggdid(attgt_dyn43)
  
  #save output as .csv
  #dynamic43
  dyn43_t<-tidy(attgt_dyn43)
  dyn43_g<-glance(attgt_dyn43)
  dyn43<-merge(dyn43_t, dyn43_g, by = "type")
  dyn43$group=NA
  dyn43$outcome=y
  dyn43$point_crit=(dyn43$estimate-dyn43$point.conf.low)/dyn43$std.error #pointwise 95% CI critical value
  dyn43$simult_crit=(dyn43$estimate-dyn43$conf.low)/dyn43$std.error #simultaneous 95% CI critical value
  setwd("C:/Users/Zachary.Fone/Dropbox/RESEARCH/RML project/empirical/analysis/exploratory_output/figures/from R/")
  write.csv(dyn43, paste(y, "_black.csv"))
  
  rm(attgt, attgt_dyn43, dyn43, dyn43_g, dyn43_t)

}

## marijuana possession/sales ####
x<-c("rate_poss_cannabis_1899", "rate_sale_cannabis_1899")

for (y in x) {
  
  set.seed(8675309)
  attgt <- att_gt(yname = y,
                  gname = "g_rml",
                  idname = "fips",
                  tname = "year",
                  weightsname = "pop_1899",
                  control_group = "nevertreated",
                  xformla = NULL,
                  panel = TRUE,
                  allow_unbalanced_panel = FALSE,
                  bstrap = TRUE, # if TRUE compute boostrapped SE
                  biters = 1000, # number of bootstrap iterations
                  clustervars = "fips", # cluster level
                  est_method = "reg",
                  base_period = "universal",
                  data = rml_black
  )
  
  # summarize the results
  #options(max.print=999999)
  #summary(attgt)
  
  # aggregate the group-time average treatment effects into event study estimates
  set.seed(8675309)
  attgt_dyn43 <- aggte(attgt, type = "dynamic", na.rm = TRUE)
  summary(attgt_dyn43)
  ggdid(attgt_dyn43)
  
  #save output as .csv
  #dynamic43
  dyn43_t<-tidy(attgt_dyn43)
  dyn43_g<-glance(attgt_dyn43)
  dyn43<-merge(dyn43_t, dyn43_g, by = "type")
  dyn43$group=NA
  dyn43$outcome=y
  dyn43$point_crit=(dyn43$estimate-dyn43$point.conf.low)/dyn43$std.error #pointwise 95% CI critical value
  dyn43$simult_crit=(dyn43$estimate-dyn43$conf.low)/dyn43$std.error #simultaneous 95% CI critical value
  setwd("C:/Users/Zachary.Fone/Dropbox/RESEARCH/RML project/empirical/analysis/exploratory_output/figures/from R/")
  write.csv(dyn43, paste(y, "_black.csv"))
  
  rm(attgt, attgt_dyn43, dyn43, dyn43_g, dyn43_t)
  
}


#### White ####

## total ####
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
                  xformla = NULL,
                  panel = TRUE,
                  allow_unbalanced_panel = FALSE,
                  bstrap = TRUE, # if TRUE compute boostrapped SE
                  biters = 1000, # number of bootstrap iterations
                  clustervars = "fips", # cluster level
                  est_method = "reg",
                  base_period = "universal",
                  data = rml_white
  )
  
  # summarize the results
  #options(max.print=999999)
  #summary(attgt)
  
  # aggregate the group-time average treatment effects into event study estimates
  set.seed(8675309)
  attgt_dyn43 <- aggte(attgt, type = "dynamic", na.rm = TRUE)
  summary(attgt_dyn43)
  ggdid(attgt_dyn43)
  
  #save output as .csv
  #dynamic43
  dyn43_t<-tidy(attgt_dyn43)
  dyn43_g<-glance(attgt_dyn43)
  dyn43<-merge(dyn43_t, dyn43_g, by = "type")
  dyn43$group=NA
  dyn43$outcome=y
  dyn43$point_crit=(dyn43$estimate-dyn43$point.conf.low)/dyn43$std.error #pointwise 95% CI critical value
  dyn43$simult_crit=(dyn43$estimate-dyn43$conf.low)/dyn43$std.error #simultaneous 95% CI critical value
  setwd("C:/Users/Zachary.Fone/Dropbox/RESEARCH/RML project/empirical/analysis/exploratory_output/figures/from R/")
  write.csv(dyn43, paste(y, "_white.csv"))
  
  rm(attgt, attgt_dyn43, dyn43, dyn43_g, dyn43_t)
  
}

## marijuana possession/sales ####
x<-c("rate_poss_cannabis_1899", "rate_sale_cannabis_1899")

for (y in x) {
  
  set.seed(8675309)
  attgt <- att_gt(yname = y,
                  gname = "g_rml",
                  idname = "fips",
                  tname = "year",
                  weightsname = "pop_1899",
                  control_group = "nevertreated",
                  xformla = NULL,
                  panel = TRUE,
                  allow_unbalanced_panel = FALSE,
                  bstrap = TRUE, # if TRUE compute boostrapped SE
                  biters = 1000, # number of bootstrap iterations
                  clustervars = "fips", # cluster level
                  est_method = "reg",
                  base_period = "universal",
                  data = rml_white
  )
  
  # summarize the results
  #options(max.print=999999)
  #summary(attgt)
  
  # aggregate the group-time average treatment effects into event study estimates
  set.seed(8675309)
  attgt_dyn43 <- aggte(attgt, type = "dynamic", na.rm = TRUE)
  summary(attgt_dyn43)
  ggdid(attgt_dyn43)
  
  #save output as .csv
  #dynamic43
  dyn43_t<-tidy(attgt_dyn43)
  dyn43_g<-glance(attgt_dyn43)
  dyn43<-merge(dyn43_t, dyn43_g, by = "type")
  dyn43$group=NA
  dyn43$outcome=y
  dyn43$point_crit=(dyn43$estimate-dyn43$point.conf.low)/dyn43$std.error #pointwise 95% CI critical value
  dyn43$simult_crit=(dyn43$estimate-dyn43$conf.low)/dyn43$std.error #simultaneous 95% CI critical value
  setwd("C:/Users/Zachary.Fone/Dropbox/RESEARCH/RML project/empirical/analysis/exploratory_output/figures/from R/")
  write.csv(dyn43, paste(y, "_white.csv"))
  
  rm(attgt, attgt_dyn43, dyn43, dyn43_g, dyn43_t)
  
}


################## With Covariates - C1 #######

#### Black ####

## total ####
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
                  xformla = ~ mml + decrim + unemployment + lnpci,
                  panel = TRUE,
                  allow_unbalanced_panel = FALSE,
                  bstrap = TRUE, # if TRUE compute boostrapped SE
                  biters = 1000, # number of bootstrap iterations
                  clustervars = "fips", # cluster level
                  est_method = "reg",
                  base_period = "universal",
                  data = rml_black
  )
  
  # summarize the results
  #options(max.print=999999)
  #summary(attgt)
  
  # aggregate the group-time average treatment effects into event study estimates
  set.seed(8675309)
  attgt_dyn43 <- aggte(attgt, type = "dynamic", na.rm = TRUE)
  summary(attgt_dyn43)
  ggdid(attgt_dyn43)
  
  #save output as .csv
  #dynamic43
  dyn43_t<-tidy(attgt_dyn43)
  dyn43_g<-glance(attgt_dyn43)
  dyn43<-merge(dyn43_t, dyn43_g, by = "type")
  dyn43$group=NA
  dyn43$outcome=y
  dyn43$point_crit=(dyn43$estimate-dyn43$point.conf.low)/dyn43$std.error #pointwise 95% CI critical value
  dyn43$simult_crit=(dyn43$estimate-dyn43$conf.low)/dyn43$std.error #simultaneous 95% CI critical value
  setwd("C:/Users/Zachary.Fone/Dropbox/RESEARCH/RML project/empirical/analysis/exploratory_output/figures/from R/")
  write.csv(dyn43, paste(y, "_black_c1.csv"))
  
  rm(attgt, attgt_dyn43, dyn43, dyn43_g, dyn43_t)
  
}

## marijuana possession/sales ####
x<-c("rate_poss_cannabis_1899", "rate_sale_cannabis_1899")

for (y in x) {
  
  set.seed(8675309)
  attgt <- att_gt(yname = y,
                  gname = "g_rml",
                  idname = "fips",
                  tname = "year",
                  weightsname = "pop_1899",
                  control_group = "nevertreated",
                  xformla = ~ mml + decrim + unemployment + lnpci,
                  panel = TRUE,
                  allow_unbalanced_panel = FALSE,
                  bstrap = TRUE, # if TRUE compute boostrapped SE
                  biters = 1000, # number of bootstrap iterations
                  clustervars = "fips", # cluster level
                  est_method = "reg",
                  base_period = "universal",
                  data = rml_black
  )
  
  # summarize the results
  #options(max.print=999999)
  #summary(attgt)
  
  # aggregate the group-time average treatment effects into event study estimates
  set.seed(8675309)
  attgt_dyn43 <- aggte(attgt, type = "dynamic", na.rm = TRUE)
  summary(attgt_dyn43)
  ggdid(attgt_dyn43)
  
  #save output as .csv
  #dynamic43
  dyn43_t<-tidy(attgt_dyn43)
  dyn43_g<-glance(attgt_dyn43)
  dyn43<-merge(dyn43_t, dyn43_g, by = "type")
  dyn43$group=NA
  dyn43$outcome=y
  dyn43$point_crit=(dyn43$estimate-dyn43$point.conf.low)/dyn43$std.error #pointwise 95% CI critical value
  dyn43$simult_crit=(dyn43$estimate-dyn43$conf.low)/dyn43$std.error #simultaneous 95% CI critical value
  setwd("C:/Users/Zachary.Fone/Dropbox/RESEARCH/RML project/empirical/analysis/exploratory_output/figures/from R/")
  write.csv(dyn43, paste(y, "_black_c1.csv"))
  
  rm(attgt, attgt_dyn43, dyn43, dyn43_g, dyn43_t)
  
}

#### White ####

## total ####
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
                  xformla = ~ mml + decrim + unemployment + lnpci,
                  panel = TRUE,
                  allow_unbalanced_panel = FALSE,
                  bstrap = TRUE, # if TRUE compute boostrapped SE
                  biters = 1000, # number of bootstrap iterations
                  clustervars = "fips", # cluster level
                  est_method = "reg",
                  base_period = "universal",
                  data = rml_white
  )
  
  # summarize the results
  #options(max.print=999999)
  #summary(attgt)
  
  # aggregate the group-time average treatment effects into event study estimates
  set.seed(8675309)
  attgt_dyn43 <- aggte(attgt, type = "dynamic", na.rm = TRUE)
  summary(attgt_dyn43)
  ggdid(attgt_dyn43)
  
  #save output as .csv
  #dynamic43
  dyn43_t<-tidy(attgt_dyn43)
  dyn43_g<-glance(attgt_dyn43)
  dyn43<-merge(dyn43_t, dyn43_g, by = "type")
  dyn43$group=NA
  dyn43$outcome=y
  dyn43$point_crit=(dyn43$estimate-dyn43$point.conf.low)/dyn43$std.error #pointwise 95% CI critical value
  dyn43$simult_crit=(dyn43$estimate-dyn43$conf.low)/dyn43$std.error #simultaneous 95% CI critical value
  setwd("C:/Users/Zachary.Fone/Dropbox/RESEARCH/RML project/empirical/analysis/exploratory_output/figures/from R/")
  write.csv(dyn43, paste(y, "_white_c1.csv"))
  
  rm(attgt, attgt_dyn43, dyn43, dyn43_g, dyn43_t)
  
}

## marijuana possession/sales ####
x<-c("rate_poss_cannabis_1899", "rate_sale_cannabis_1899")

for (y in x) {
  
  set.seed(8675309)
  attgt <- att_gt(yname = y,
                  gname = "g_rml",
                  idname = "fips",
                  tname = "year",
                  weightsname = "pop_1899",
                  control_group = "nevertreated",
                  xformla = ~ mml + decrim + unemployment + lnpci,
                  panel = TRUE,
                  allow_unbalanced_panel = FALSE,
                  bstrap = TRUE, # if TRUE compute boostrapped SE
                  biters = 1000, # number of bootstrap iterations
                  clustervars = "fips", # cluster level
                  est_method = "reg",
                  base_period = "universal",
                  data = rml_white
  )
  
  # summarize the results
  #options(max.print=999999)
  #summary(attgt)
  
  # aggregate the group-time average treatment effects into event study estimates
  set.seed(8675309)
  attgt_dyn43 <- aggte(attgt, type = "dynamic", na.rm = TRUE)
  summary(attgt_dyn43)
  ggdid(attgt_dyn43)
  
  #save output as .csv
  #dynamic43
  dyn43_t<-tidy(attgt_dyn43)
  dyn43_g<-glance(attgt_dyn43)
  dyn43<-merge(dyn43_t, dyn43_g, by = "type")
  dyn43$group=NA
  dyn43$outcome=y
  dyn43$point_crit=(dyn43$estimate-dyn43$point.conf.low)/dyn43$std.error #pointwise 95% CI critical value
  dyn43$simult_crit=(dyn43$estimate-dyn43$conf.low)/dyn43$std.error #simultaneous 95% CI critical value
  setwd("C:/Users/Zachary.Fone/Dropbox/RESEARCH/RML project/empirical/analysis/exploratory_output/figures/from R/")
  write.csv(dyn43, paste(y, "_white_c1.csv"))
  
  rm(attgt, attgt_dyn43, dyn43, dyn43_g, dyn43_t)
  
}


################## With Covariates: LEA + MML + MDL #######

#### Black ####

## total ####
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
                  xformla = ~ mml + decrim + num_agencies_report,
                  panel = TRUE,
                  allow_unbalanced_panel = FALSE,
                  bstrap = TRUE, # if TRUE compute boostrapped SE
                  biters = 1000, # number of bootstrap iterations
                  clustervars = "fips", # cluster level
                  est_method = "reg",
                  base_period = "universal",
                  data = rml_black
  )
  
  # summarize the results
  #options(max.print=999999)
  #summary(attgt)
  
  # aggregate the group-time average treatment effects into event study estimates
  set.seed(8675309)
  attgt_dyn43 <- aggte(attgt, type = "dynamic", na.rm = TRUE)
  summary(attgt_dyn43)
  ggdid(attgt_dyn43)
  
  #save output as .csv
  #dynamic43
  dyn43_t<-tidy(attgt_dyn43)
  dyn43_g<-glance(attgt_dyn43)
  dyn43<-merge(dyn43_t, dyn43_g, by = "type")
  dyn43$group=NA
  dyn43$outcome=y
  dyn43$point_crit=(dyn43$estimate-dyn43$point.conf.low)/dyn43$std.error #pointwise 95% CI critical value
  dyn43$simult_crit=(dyn43$estimate-dyn43$conf.low)/dyn43$std.error #simultaneous 95% CI critical value
  setwd("C:/Users/Zachary.Fone/Dropbox/RESEARCH/RML project/empirical/analysis/exploratory_output/figures/from R/")
  write.csv(dyn43, paste(y, "_black_lea-mml-mdl.csv"))
  
  rm(attgt, attgt_dyn43, dyn43, dyn43_g, dyn43_t)
  
}

## marijuana possession/sales ####
x<-c("rate_poss_cannabis_1899", "rate_sale_cannabis_1899")

for (y in x) {
  
  set.seed(8675309)
  attgt <- att_gt(yname = y,
                  gname = "g_rml",
                  idname = "fips",
                  tname = "year",
                  weightsname = "pop_1899",
                  control_group = "nevertreated",
                  xformla = ~ mml + decrim + num_agencies_report,
                  panel = TRUE,
                  allow_unbalanced_panel = FALSE,
                  bstrap = TRUE, # if TRUE compute boostrapped SE
                  biters = 1000, # number of bootstrap iterations
                  clustervars = "fips", # cluster level
                  est_method = "reg",
                  base_period = "universal",
                  data = rml_black
  )
  
  # summarize the results
  #options(max.print=999999)
  #summary(attgt)
  
  # aggregate the group-time average treatment effects into event study estimates
  set.seed(8675309)
  attgt_dyn43 <- aggte(attgt, type = "dynamic", na.rm = TRUE)
  summary(attgt_dyn43)
  ggdid(attgt_dyn43)
  
  #save output as .csv
  #dynamic43
  dyn43_t<-tidy(attgt_dyn43)
  dyn43_g<-glance(attgt_dyn43)
  dyn43<-merge(dyn43_t, dyn43_g, by = "type")
  dyn43$group=NA
  dyn43$outcome=y
  dyn43$point_crit=(dyn43$estimate-dyn43$point.conf.low)/dyn43$std.error #pointwise 95% CI critical value
  dyn43$simult_crit=(dyn43$estimate-dyn43$conf.low)/dyn43$std.error #simultaneous 95% CI critical value
  setwd("C:/Users/Zachary.Fone/Dropbox/RESEARCH/RML project/empirical/analysis/exploratory_output/figures/from R/")
  write.csv(dyn43, paste(y, "_black_lea-mml-mdl.csv"))
  
  rm(attgt, attgt_dyn43, dyn43, dyn43_g, dyn43_t)
  
}

#### White ####

## total ####
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
                  xformla = ~ mml + decrim + num_agencies_report,
                  panel = TRUE,
                  allow_unbalanced_panel = FALSE,
                  bstrap = TRUE, # if TRUE compute boostrapped SE
                  biters = 1000, # number of bootstrap iterations
                  clustervars = "fips", # cluster level
                  est_method = "reg",
                  base_period = "universal",
                  data = rml_white
  )
  
  # summarize the results
  #options(max.print=999999)
  #summary(attgt)
  
  # aggregate the group-time average treatment effects into event study estimates
  set.seed(8675309)
  attgt_dyn43 <- aggte(attgt, type = "dynamic", na.rm = TRUE)
  summary(attgt_dyn43)
  ggdid(attgt_dyn43)
  
  #save output as .csv
  #dynamic43
  dyn43_t<-tidy(attgt_dyn43)
  dyn43_g<-glance(attgt_dyn43)
  dyn43<-merge(dyn43_t, dyn43_g, by = "type")
  dyn43$group=NA
  dyn43$outcome=y
  dyn43$point_crit=(dyn43$estimate-dyn43$point.conf.low)/dyn43$std.error #pointwise 95% CI critical value
  dyn43$simult_crit=(dyn43$estimate-dyn43$conf.low)/dyn43$std.error #simultaneous 95% CI critical value
  setwd("C:/Users/Zachary.Fone/Dropbox/RESEARCH/RML project/empirical/analysis/exploratory_output/figures/from R/")
  write.csv(dyn43, paste(y, "_white_lea-mml-mdl.csv"))
  
  rm(attgt, attgt_dyn43, dyn43, dyn43_g, dyn43_t)
  
}

## marijuana possession/sales ####
x<-c("rate_poss_cannabis_1899", "rate_sale_cannabis_1899")

for (y in x) {
  
  set.seed(8675309)
  attgt <- att_gt(yname = y,
                  gname = "g_rml",
                  idname = "fips",
                  tname = "year",
                  weightsname = "pop_1899",
                  control_group = "nevertreated",
                  xformla = ~ mml + decrim + num_agencies_report,
                  panel = TRUE,
                  allow_unbalanced_panel = FALSE,
                  bstrap = TRUE, # if TRUE compute boostrapped SE
                  biters = 1000, # number of bootstrap iterations
                  clustervars = "fips", # cluster level
                  est_method = "reg",
                  base_period = "universal",
                  data = rml_white
  )
  
  # summarize the results
  #options(max.print=999999)
  #summary(attgt)
  
  # aggregate the group-time average treatment effects into event study estimates
  set.seed(8675309)
  attgt_dyn43 <- aggte(attgt, type = "dynamic", na.rm = TRUE)
  summary(attgt_dyn43)
  ggdid(attgt_dyn43)
  
  #save output as .csv
  #dynamic43
  dyn43_t<-tidy(attgt_dyn43)
  dyn43_g<-glance(attgt_dyn43)
  dyn43<-merge(dyn43_t, dyn43_g, by = "type")
  dyn43$group=NA
  dyn43$outcome=y
  dyn43$point_crit=(dyn43$estimate-dyn43$point.conf.low)/dyn43$std.error #pointwise 95% CI critical value
  dyn43$simult_crit=(dyn43$estimate-dyn43$conf.low)/dyn43$std.error #simultaneous 95% CI critical value
  setwd("C:/Users/Zachary.Fone/Dropbox/RESEARCH/RML project/empirical/analysis/exploratory_output/figures/from R/")
  write.csv(dyn43, paste(y, "_white_lea-mml-mdl.csv"))
  
  rm(attgt, attgt_dyn43, dyn43, dyn43_g, dyn43_t)
  
}


################## With Covariates - C1 + LEA #######

#### Black ####

## total ####
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
                  bstrap = TRUE, # if TRUE compute boostrapped SE
                  biters = 1000, # number of bootstrap iterations
                  clustervars = "fips", # cluster level
                  est_method = "reg",
                  base_period = "universal",
                  data = rml_black
  )
  
  # summarize the results
  #options(max.print=999999)
  #summary(attgt)
  
  # aggregate the group-time average treatment effects into event study estimates
  set.seed(8675309)
  attgt_dyn43 <- aggte(attgt, type = "dynamic", na.rm = TRUE)
  summary(attgt_dyn43)
  ggdid(attgt_dyn43)
  
  #save output as .csv
  #dynamic43
  dyn43_t<-tidy(attgt_dyn43)
  dyn43_g<-glance(attgt_dyn43)
  dyn43<-merge(dyn43_t, dyn43_g, by = "type")
  dyn43$group=NA
  dyn43$outcome=y
  dyn43$point_crit=(dyn43$estimate-dyn43$point.conf.low)/dyn43$std.error #pointwise 95% CI critical value
  dyn43$simult_crit=(dyn43$estimate-dyn43$conf.low)/dyn43$std.error #simultaneous 95% CI critical value
  setwd("C:/Users/Zachary.Fone/Dropbox/RESEARCH/RML project/empirical/analysis/exploratory_output/figures/from R/")
  write.csv(dyn43, paste(y, "_black_c1-lea.csv"))
  
  rm(attgt, attgt_dyn43, dyn43, dyn43_g, dyn43_t)
  
}

## marijuana possession/sales ####
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
                  bstrap = TRUE, # if TRUE compute boostrapped SE
                  biters = 1000, # number of bootstrap iterations
                  clustervars = "fips", # cluster level
                  est_method = "reg",
                  base_period = "universal",
                  data = rml_black
  )
  
  # summarize the results
  #options(max.print=999999)
  #summary(attgt)
  
  # aggregate the group-time average treatment effects into event study estimates
  set.seed(8675309)
  attgt_dyn43 <- aggte(attgt, type = "dynamic", na.rm = TRUE)
  summary(attgt_dyn43)
  ggdid(attgt_dyn43)
  
  #save output as .csv
  #dynamic43
  dyn43_t<-tidy(attgt_dyn43)
  dyn43_g<-glance(attgt_dyn43)
  dyn43<-merge(dyn43_t, dyn43_g, by = "type")
  dyn43$group=NA
  dyn43$outcome=y
  dyn43$point_crit=(dyn43$estimate-dyn43$point.conf.low)/dyn43$std.error #pointwise 95% CI critical value
  dyn43$simult_crit=(dyn43$estimate-dyn43$conf.low)/dyn43$std.error #simultaneous 95% CI critical value
  setwd("C:/Users/Zachary.Fone/Dropbox/RESEARCH/RML project/empirical/analysis/exploratory_output/figures/from R/")
  write.csv(dyn43, paste(y, "_black_c1-lea.csv"))
  
  rm(attgt, attgt_dyn43, dyn43, dyn43_g, dyn43_t)
  
}

#### White ####

## total ####
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
                  bstrap = TRUE, # if TRUE compute boostrapped SE
                  biters = 1000, # number of bootstrap iterations
                  clustervars = "fips", # cluster level
                  est_method = "reg",
                  base_period = "universal",
                  data = rml_white
  )
  
  # summarize the results
  #options(max.print=999999)
  #summary(attgt)
  
  # aggregate the group-time average treatment effects into event study estimates
  set.seed(8675309)
  attgt_dyn43 <- aggte(attgt, type = "dynamic", na.rm = TRUE)
  summary(attgt_dyn43)
  ggdid(attgt_dyn43)
  
  #save output as .csv
  #dynamic43
  dyn43_t<-tidy(attgt_dyn43)
  dyn43_g<-glance(attgt_dyn43)
  dyn43<-merge(dyn43_t, dyn43_g, by = "type")
  dyn43$group=NA
  dyn43$outcome=y
  dyn43$point_crit=(dyn43$estimate-dyn43$point.conf.low)/dyn43$std.error #pointwise 95% CI critical value
  dyn43$simult_crit=(dyn43$estimate-dyn43$conf.low)/dyn43$std.error #simultaneous 95% CI critical value
  setwd("C:/Users/Zachary.Fone/Dropbox/RESEARCH/RML project/empirical/analysis/exploratory_output/figures/from R/")
  write.csv(dyn43, paste(y, "_white_c1-lea.csv"))
  
  rm(attgt, attgt_dyn43, dyn43, dyn43_g, dyn43_t)
  
}

## marijuana possession/sales ####
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
                  bstrap = TRUE, # if TRUE compute boostrapped SE
                  biters = 1000, # number of bootstrap iterations
                  clustervars = "fips", # cluster level
                  est_method = "reg",
                  base_period = "universal",
                  data = rml_white
  )
  
  # summarize the results
  #options(max.print=999999)
  #summary(attgt)
  
  # aggregate the group-time average treatment effects into event study estimates
  set.seed(8675309)
  attgt_dyn43 <- aggte(attgt, type = "dynamic", na.rm = TRUE)
  summary(attgt_dyn43)
  ggdid(attgt_dyn43)
  
  #save output as .csv
  #dynamic43
  dyn43_t<-tidy(attgt_dyn43)
  dyn43_g<-glance(attgt_dyn43)
  dyn43<-merge(dyn43_t, dyn43_g, by = "type")
  dyn43$group=NA
  dyn43$outcome=y
  dyn43$point_crit=(dyn43$estimate-dyn43$point.conf.low)/dyn43$std.error #pointwise 95% CI critical value
  dyn43$simult_crit=(dyn43$estimate-dyn43$conf.low)/dyn43$std.error #simultaneous 95% CI critical value
  setwd("C:/Users/Zachary.Fone/Dropbox/RESEARCH/RML project/empirical/analysis/exploratory_output/figures/from R/")
  write.csv(dyn43, paste(y, "_white_c1-lea.csv"))
  
  rm(attgt, attgt_dyn43, dyn43, dyn43_g, dyn43_t)
  
}


