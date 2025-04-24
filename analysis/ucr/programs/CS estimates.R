###############################
#name: CS estimates.R
###############################
#install.packages("readstata13")
library(readstata13)
#install.packages("did")
library(did)

#load analysis data (UPDATE FILE PATH)
black <- read.dta13("C:/Users/Zachary.Fone/Desktop/RML/data/ucr/data/analysis_files/rml_black.dta")
white <- read.dta13("C:/Users/Zachary.Fone/Desktop/RML/data/ucr/data/analysis_files/rml_white.dta")
black_sales <- read.dta13("C:/Users/Zachary.Fone/Desktop/RML/data/ucr/data/analysis_files/rml_black_sales.dta")
white_sales <- read.dta13("C:/Users/Zachary.Fone/Desktop/RML/data/ucr/data/analysis_files/rml_white_sales.dta")
black_nosales <- read.dta13("C:/Users/Zachary.Fone/Desktop/RML/data/ucr/data/analysis_files/rml_black_nosales.dta")
white_nosales <- read.dta13("C:/Users/Zachary.Fone/Desktop/RML/data/ucr/data/analysis_files/rml_white_nosales.dta")

#set your directory (UPDATE FILE PATH)
setwd("C:/Users/Zachary.Fone/Desktop/RML/analysis/ucr/CS output/")

################# Static/Event Study Estimates ####
#### Black: not yet treated ####
x<-c("rate_total_cannabis_1899", "rate_total_nonmj_1899", "rate_total_property_1899", "rate_total_violent_1899",
     "rate_total_heroin_coke_1899", "rate_total_synth_narc_1899", "rate_total_other_drug_1899")

for (y in x) {
  
  set.seed(8675309)
  attgt <- att_gt(yname = y,
                  gname = "g_rml",
                  idname = "fips",
                  tname = "year",
                  weightsname = "pop_1899",
                  control_group = "notyettreated",
                  xformla = ~ mml + decrim + unemployment + lnpci + number_of_months_reported + report_share_seer,
                  panel = TRUE,
                  allow_unbalanced_panel = FALSE,
                  bstrap = TRUE,
                  biters = 1000, 
                  clustervars = "fips", 
                  est_method = "reg",
                  base_period = "universal",
                  data = black
  )
  
  # aggregate - simple
  set.seed(8675309)
  simple <- aggte(attgt, type = "simple", na.rm = TRUE)
  #pvalue 
  p_value <- 2 * (1 - pnorm(abs(simple$overall.att / simple$overall.se)))
  
  #save output as .csv
  #simple
  simple_t<-tidy(simple)
  simple_g<-glance(simple)
  sim<-merge(simple_t, simple_g, by = "type")
  sim$group=NA
  sim$outcome=y
  sim$point_crit=(sim$estimate-sim$point.conf.low)/sim$std.error #pointwise 95% CI critical value
  sim$simult_crit=(sim$estimate-sim$conf.low)/sim$std.error #simultaneous 95% CI critical value
  sim$pval=p_value
  write.csv(sim, paste(y, "static_black_ny.csv"))
  
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
  write.csv(dyn, paste(y, "es_black_ny.csv"))
  
  rm(attgt, simple, sim, simple_g, simple_t, p_value, attgt_dyn, dyn, dyn_g, dyn_t)
  
}

#### Black: not yet treated - no covariates ####
x<-c("rate_total_cannabis_1899", "rate_total_nonmj_1899", "rate_total_property_1899", "rate_total_violent_1899",
     "rate_total_heroin_coke_1899", "rate_total_synth_narc_1899", "rate_total_other_drug_1899")

for (y in x) {
  
  set.seed(8675309)
  attgt <- att_gt(yname = y,
                  gname = "g_rml",
                  idname = "fips",
                  tname = "year",
                  weightsname = "pop_1899",
                  control_group = "notyettreated",
                  xformla = NULL,
                  panel = TRUE,
                  allow_unbalanced_panel = FALSE,
                  bstrap = TRUE,
                  biters = 1000, 
                  clustervars = "fips", 
                  est_method = "reg",
                  base_period = "universal",
                  data = black
  )
  
  # aggregate - simple
  set.seed(8675309)
  simple <- aggte(attgt, type = "simple", na.rm = TRUE)
  #pvalue 
  p_value <- 2 * (1 - pnorm(abs(simple$overall.att / simple$overall.se)))
  
  #save output as .csv
  #simple
  simple_t<-tidy(simple)
  simple_g<-glance(simple)
  sim<-merge(simple_t, simple_g, by = "type")
  sim$group=NA
  sim$outcome=y
  sim$point_crit=(sim$estimate-sim$point.conf.low)/sim$std.error #pointwise 95% CI critical value
  sim$simult_crit=(sim$estimate-sim$conf.low)/sim$std.error #simultaneous 95% CI critical value
  sim$pval=p_value
  write.csv(sim, paste(y, "static_black_ny_noX.csv"))
  
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
  write.csv(dyn, paste(y, "es_black_ny_noX.csv"))
  
  rm(attgt, simple, sim, simple_g, simple_t, p_value, attgt_dyn, dyn, dyn_g, dyn_t)
  
}

#### White: not yet treated ####
x<-c("rate_total_cannabis_1899", "rate_total_nonmj_1899", "rate_total_property_1899", "rate_total_violent_1899",
     "rate_total_heroin_coke_1899", "rate_total_synth_narc_1899", "rate_total_other_drug_1899")

for (y in x) {
  
  set.seed(8675309)
  attgt <- att_gt(yname = y,
                  gname = "g_rml",
                  idname = "fips",
                  tname = "year",
                  weightsname = "pop_1899",
                  control_group = "notyettreated",
                  xformla = ~ mml + decrim + unemployment + lnpci + number_of_months_reported + report_share_seer,
                  panel = TRUE,
                  allow_unbalanced_panel = FALSE,
                  bstrap = TRUE,
                  biters = 1000, 
                  clustervars = "fips", 
                  est_method = "reg",
                  base_period = "universal",
                  data = white
  )
  
  # aggregate - simple
  set.seed(8675309)
  simple <- aggte(attgt, type = "simple", na.rm = TRUE)
  #pvalue 
  p_value <- 2 * (1 - pnorm(abs(simple$overall.att / simple$overall.se)))
  
  #save output as .csv
  #simple
  simple_t<-tidy(simple)
  simple_g<-glance(simple)
  sim<-merge(simple_t, simple_g, by = "type")
  sim$group=NA
  sim$outcome=y
  sim$point_crit=(sim$estimate-sim$point.conf.low)/sim$std.error #pointwise 95% CI critical value
  sim$simult_crit=(sim$estimate-sim$conf.low)/sim$std.error #simultaneous 95% CI critical value
  sim$pval=p_value
  write.csv(sim, paste(y, "static_white_ny.csv"))
  
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
  write.csv(dyn, paste(y, "es_white_ny.csv"))
  
  rm(attgt, simple, sim, simple_g, simple_t, p_value, attgt_dyn, dyn, dyn_g, dyn_t)
  
}

#### White: not yet treated - no covariates ####
x<-c("rate_total_cannabis_1899", "rate_total_nonmj_1899", "rate_total_property_1899", "rate_total_violent_1899",
     "rate_total_heroin_coke_1899", "rate_total_synth_narc_1899", "rate_total_other_drug_1899")

for (y in x) {
  
  set.seed(8675309)
  attgt <- att_gt(yname = y,
                  gname = "g_rml",
                  idname = "fips",
                  tname = "year",
                  weightsname = "pop_1899",
                  control_group = "notyettreated",
                  xformla = NULL,
                  panel = TRUE,
                  allow_unbalanced_panel = FALSE,
                  bstrap = TRUE,
                  biters = 1000, 
                  clustervars = "fips", 
                  est_method = "reg",
                  base_period = "universal",
                  data = white
  )
  
  # aggregate - simple
  set.seed(8675309)
  simple <- aggte(attgt, type = "simple", na.rm = TRUE)
  #pvalue 
  p_value <- 2 * (1 - pnorm(abs(simple$overall.att / simple$overall.se)))
  
  #save output as .csv
  #simple
  simple_t<-tidy(simple)
  simple_g<-glance(simple)
  sim<-merge(simple_t, simple_g, by = "type")
  sim$group=NA
  sim$outcome=y
  sim$point_crit=(sim$estimate-sim$point.conf.low)/sim$std.error #pointwise 95% CI critical value
  sim$simult_crit=(sim$estimate-sim$conf.low)/sim$std.error #simultaneous 95% CI critical value
  sim$pval=p_value
  write.csv(sim, paste(y, "static_white_ny_noX.csv"))
  
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
  write.csv(dyn, paste(y, "es_white_ny_noX.csv"))
  
  rm(attgt, simple, sim, simple_g, simple_t, p_value, attgt_dyn, dyn, dyn_g, dyn_t)
  
}


################# RML Sales/No Sales Estimates ####
#### Black: no sales ####
x<-c("rate_total_cannabis_1899", "rate_total_nonmj_1899", "rate_total_property_1899", "rate_total_violent_1899")

for (y in x) {
  
  set.seed(8675309)
  attgt <- att_gt(yname = y,
                  gname = "g_rml_no_sales",
                  idname = "fips",
                  tname = "year",
                  weightsname = "pop_1899",
                  control_group = "notyettreated",
                  xformla = ~ mml + decrim + unemployment + lnpci + number_of_months_reported + report_share_seer,
                  panel = TRUE,
                  allow_unbalanced_panel = FALSE,
                  bstrap = TRUE,
                  biters = 1000, 
                  clustervars = "fips", 
                  est_method = "reg",
                  base_period = "universal",
                  data = black_nosales
  )
  
  # aggregate - simple
  set.seed(8675309)
  simple <- aggte(attgt, type = "simple", na.rm = TRUE)
  #pvalue 
  p_value <- 2 * (1 - pnorm(abs(simple$overall.att / simple$overall.se)))
  
  #save output as .csv
  #simple
  simple_t<-tidy(simple)
  simple_g<-glance(simple)
  sim<-merge(simple_t, simple_g, by = "type")
  sim$group=NA
  sim$outcome=y
  sim$point_crit=(sim$estimate-sim$point.conf.low)/sim$std.error #pointwise 95% CI critical value
  sim$simult_crit=(sim$estimate-sim$conf.low)/sim$std.error #simultaneous 95% CI critical value
  sim$pval=p_value
  write.csv(sim, paste(y, "static_black_nosales_ny.csv"))
  
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
  write.csv(dyn, paste(y, "es_black_nosales_ny.csv"))
  
  rm(attgt, simple, sim, simple_g, simple_t, p_value, attgt_dyn, dyn, dyn_g, dyn_t)
  
}

#### Black: sales ####
x<-c("rate_total_cannabis_1899", "rate_total_nonmj_1899", "rate_total_property_1899", "rate_total_violent_1899")

for (y in x) {
  
  set.seed(8675309)
  attgt <- att_gt(yname = y,
                  gname = "g_rml_no_sales",
                  idname = "fips",
                  tname = "year",
                  weightsname = "pop_1899",
                  control_group = "notyettreated",
                  xformla = ~ mml + decrim + unemployment + lnpci + number_of_months_reported + report_share_seer,
                  panel = TRUE,
                  allow_unbalanced_panel = FALSE,
                  bstrap = TRUE,
                  biters = 1000, 
                  clustervars = "fips", 
                  est_method = "reg",
                  base_period = "universal",
                  data = black_sales
  )
  
  # aggregate - simple
  set.seed(8675309)
  simple <- aggte(attgt, type = "simple", na.rm = TRUE)
  #pvalue 
  p_value <- 2 * (1 - pnorm(abs(simple$overall.att / simple$overall.se)))
  
  #save output as .csv
  #simple
  simple_t<-tidy(simple)
  simple_g<-glance(simple)
  sim<-merge(simple_t, simple_g, by = "type")
  sim$group=NA
  sim$outcome=y
  sim$point_crit=(sim$estimate-sim$point.conf.low)/sim$std.error #pointwise 95% CI critical value
  sim$simult_crit=(sim$estimate-sim$conf.low)/sim$std.error #simultaneous 95% CI critical value
  sim$pval=p_value
  write.csv(sim, paste(y, "static_black_sales_ny.csv"))
  
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
  write.csv(dyn, paste(y, "es_black_sales_ny.csv"))
  
  rm(attgt, simple, sim, simple_g, simple_t, p_value, attgt_dyn, dyn, dyn_g, dyn_t)
  
}


#### White: no sales ####
x<-c("rate_total_cannabis_1899", "rate_total_nonmj_1899", "rate_total_property_1899", "rate_total_violent_1899")

for (y in x) {
  
  set.seed(8675309)
  attgt <- att_gt(yname = y,
                  gname = "g_rml_no_sales",
                  idname = "fips",
                  tname = "year",
                  weightsname = "pop_1899",
                  control_group = "notyettreated",
                  xformla = ~ mml + decrim + unemployment + lnpci + number_of_months_reported + report_share_seer,
                  panel = TRUE,
                  allow_unbalanced_panel = FALSE,
                  bstrap = TRUE,
                  biters = 1000, 
                  clustervars = "fips", 
                  est_method = "reg",
                  base_period = "universal",
                  data = white_nosales
  )
  
  # aggregate - simple
  set.seed(8675309)
  simple <- aggte(attgt, type = "simple", na.rm = TRUE)
  #pvalue 
  p_value <- 2 * (1 - pnorm(abs(simple$overall.att / simple$overall.se)))
  
  #save output as .csv
  #simple
  simple_t<-tidy(simple)
  simple_g<-glance(simple)
  sim<-merge(simple_t, simple_g, by = "type")
  sim$group=NA
  sim$outcome=y
  sim$point_crit=(sim$estimate-sim$point.conf.low)/sim$std.error #pointwise 95% CI critical value
  sim$simult_crit=(sim$estimate-sim$conf.low)/sim$std.error #simultaneous 95% CI critical value
  sim$pval=p_value
  write.csv(sim, paste(y, "static_white_nosales_ny.csv"))
  
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
  write.csv(dyn, paste(y, "es_white_nosales_ny.csv"))
  
  rm(attgt, simple, sim, simple_g, simple_t, p_value, attgt_dyn, dyn, dyn_g, dyn_t)
  
}

#### White: sales ####
x<-c("rate_total_cannabis_1899", "rate_total_nonmj_1899", "rate_total_property_1899", "rate_total_violent_1899")

for (y in x) {
  
  set.seed(8675309)
  attgt <- att_gt(yname = y,
                  gname = "g_rml_no_sales",
                  idname = "fips",
                  tname = "year",
                  weightsname = "pop_1899",
                  control_group = "notyettreated",
                  xformla = ~ mml + decrim + unemployment + lnpci + number_of_months_reported + report_share_seer,
                  panel = TRUE,
                  allow_unbalanced_panel = FALSE,
                  bstrap = TRUE,
                  biters = 1000, 
                  clustervars = "fips", 
                  est_method = "reg",
                  base_period = "universal",
                  data = white_sales
  )
  
  # aggregate - simple
  set.seed(8675309)
  simple <- aggte(attgt, type = "simple", na.rm = TRUE)
  #pvalue 
  p_value <- 2 * (1 - pnorm(abs(simple$overall.att / simple$overall.se)))
  
  #save output as .csv
  #simple
  simple_t<-tidy(simple)
  simple_g<-glance(simple)
  sim<-merge(simple_t, simple_g, by = "type")
  sim$group=NA
  sim$outcome=y
  sim$point_crit=(sim$estimate-sim$point.conf.low)/sim$std.error #pointwise 95% CI critical value
  sim$simult_crit=(sim$estimate-sim$conf.low)/sim$std.error #simultaneous 95% CI critical value
  sim$pval=p_value
  write.csv(sim, paste(y, "static_white_sales_ny.csv"))
  
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
  write.csv(dyn, paste(y, "es_white_sales_ny.csv"))
  
  rm(attgt, simple, sim, simple_g, simple_t, p_value, attgt_dyn, dyn, dyn_g, dyn_t)
  
}






