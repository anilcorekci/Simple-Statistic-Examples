library(dplyr)
library(lavaan)
source("utils.R")

df <- data.frame(
  age_groups = rep(c("young", "middle", "older"), each = 5),
  performance = c(
    c(9, 8, 7, 9, 8),
    c(6, 6, 7, 6, 9),
    c(5, 7, 6, 6, 7)
  )
)

#find mean and standard deviation and variances for each group
base_stats <- df %>%
  group_by(age_groups) %>%
  summarise(mean = mean(performance),
    sd = round(sd(performance), 3),
    variances = var(performance)
  )

base_stats
# fit the model
# Load the car package for Levene's test
# and Anova for table feature!
library(car)

# model <- lm(performance ~ age_groups, data = df)
model <- aov(performance ~ age_groups, data = df)

names(model)
model_anova <- Anova(model)
names(model_anova)

ss_loadings <-  model_anova["Sum Sq"]
ms_loadings <-  model_anova["Sum Sq"] / model_anova["Df"]

colnames(ms_loadings)[which(names(ms_loadings) == "Sum Sq")] <- "MS Between"
colnames(ss_loadings)[which(names(ss_loadings) == "Sum Sq")] <- "SS Between"

tukey_h <- TukeyHSD(model, conf.level = 0.95)

library(effectsize)
eta <- eta_squared(model)
interpret_eta_squared(eta, rules = "cohen1992")

influence_resid <- get_influence(model, dvi = df$performance)

fit_list <- list(
  `Summary Statistic` = base_stats,
  `Normality & Homogeneity` = check_test_data(model),
  `Loadings` =  data.frame(
    "SS_Loadings" = round(ss_loadings, 3),
    "MS Loadings" = round(ms_loadings, 3),
    "F stat" = round(model_anova$F, 3),
    "P Value" = round(model_anova$P, 3)
  ),
  `Tukey HSD` = tukey_h$age_groups,
  `Effect Size` = t(as.data.frame(eta, row.names = "Effect Size")),
  `Residuals & Influence Measures` = influence_resid
)


export_smart(fit_list, "One_Way_ANOVA.csv")

# filter example
# young <- filter(df, age_groups == "young")["performance"]
#view the model output
#sink('summary.csv')
#summary(model_anova)
#sink()
##### --- Textbook calculations --- #####
# Ni eqs to 5 from each class length since all are equal
ss_between <- 5 * (base_stats$mean - mean(base_stats$mean))^2
ss_between <- sum(ss_between)

#Ni -1	 is 4
# since Nper eq 5 N -1 is 4
ss_within <- sum(4 * base_stats$variances)

#df_between	 = K – 1
# since K eq 3 df_between is 2
ms_between <- ss_between / 2

# ms_within eq to ss_within /df_within is N - k, 12
ms_within <- ss_within / 12

# f_stat eqs to ms_between/ ms_within
f_stat <- ms_between / ms_within

# f_stat to p-value
#F_value, df_between is 2, df_within eq N - k, 12
p_val_tbook <- pf(f_stat, 2, 12)

one_way_anova_textbook <- data.frame(
  "SS_Within" = ss_within,
  "SS_Between" = ss_between,
  "MS_Within" = ms_within,
  "MS_Between" = ms_between,
  "F_Value" = f_stat,
  "P_Value" = 1 - p_val_tbook
)

print(round(t(one_way_anova_textbook), 3))
##### --- Textbook calculations ends here--- #####