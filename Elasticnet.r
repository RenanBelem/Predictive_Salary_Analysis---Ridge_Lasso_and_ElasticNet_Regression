# Instalando pacotes necessários (se ainda não instalados)
install.packages("plyr")
install.packages("readr")
install.packages("dplyr")
install.packages("caret")
install.packages("ggplot2")
install.packages("glmnet")

# Carregando pacotes
library(plyr)
library(readr)
library(dplyr)
library(caret)
library(ggplot2)
library(glmnet)

# Configurando diretório
setwd("C:\\Users\\guto_\\Desktop\\pos-grad-iaa\\Estatistica-II")
load("trabalhosalarios.RData")

# Visualizando base
dt <- trabalhosalarios
glimpse(dt)

# Separando dados
set.seed(302)
d_indx <- sample(1:nrow(dt), 0.8 * nrow(dt))
train <- dt[d_indx, ]
test <- dt[-d_indx, ]

# Variáveis contínuas
vars_cont <- c('husage', 'husearns', 'huseduc', 'hushrs', 
               'age', 'educ', 'exper')

# Padronizando
pre_proc_val <- preProcess(train[, vars_cont], method = c("center", "scale"))
train[, vars_cont] <- predict(pre_proc_val, train[, vars_cont])
test[, vars_cont] <- predict(pre_proc_val, test[, vars_cont])

# Criando variáveis dummy
data_col <- c('husage','husunion','husearns','huseduc','husblck',
              'hushisp','hushrs','kidge6','age','black','educ',
              'hispanic','union','exper','kidlt6','lwage')

dummies <- dummyVars(~husage + husunion + husearns + huseduc + husblck + hushisp +
                       hushrs + kidge6 + age + black + educ + hispanic + union + exper + kidlt6, 
                     data = dt[data_col])

train_dummies <- predict(dummies, newdata = train[, data_col])
test_dummies <- predict(dummies, newdata = test[, data_col])

# Convertendo para matriz
x_train <- as.matrix(train_dummies)
y_train <- train$lwage
x_test <- as.matrix(test_dummies)
y_test <- test$lwage

# Função de avaliação: RMSE e R²
eval_results <- function(true, predicted, df) {
  SSE <- sum((predicted - true)^2)
  SST <- sum((true - mean(true))^2)
  R_square <- 1 - SSE / SST
  RMSE <- sqrt(SSE / nrow(df))
  
  data.frame(
    RMSE = RMSE,
    Rsquare = R_square
  )
}

# Treinamento Elastic Net
elastic_reg <- train(lwage ~ husage + husunion + husearns + huseduc + husblck + 
                       hushisp + hushrs + kidge6 + age + black + educ + 
                       hispanic + union + exper + kidlt6, 
                     data = train, 
                     method = "glmnet", 
                     trControl = traincontrol, 
                     tuneLength = 10)

# Avaliação Elastic Net
predictions_train_elastic <- predict(elastic_reg, x_train)
eval_results(y_train, predictions_train_elastic, train)

predictions_test_elastic <- predict(elastic_reg, x_test)
eval_results(y_test, predictions_test_elastic, test)

# --- Predição para os valores especificados ---
husage <- (40 - pre_proc_val$mean['husage']) / pre_proc_val$std['husage']
husunion <- 0
husearns <- (600 - pre_proc_val$mean['husearns']) / pre_proc_val$std['husearns']
huseduc <- (13 - pre_proc_val$mean['huseduc']) / pre_proc_val$std['huseduc']
husblck <- 1
hushisp <- 0
hushrs <- (40 - pre_proc_val$mean['hushrs']) / pre_proc_val$std['hushrs']
kidge6 <- 1
age <- (38 - pre_proc_val$mean['age']) / pre_proc_val$std['age']
black <- 0
educ <- (13 - pre_proc_val$mean['educ']) / pre_proc_val$std['educ']
hispanic <- 1
union <- 0
exper <- (18 - pre_proc_val$mean['exper']) / pre_proc_val$std['exper']
kidlt6 <- 1

our_pred <- as.data.frame(list(husage = husage,
                               husunion = husunion,
                               husearns = husearns,
                               huseduc = huseduc,
                               husblck = husblck,
                               hushisp = hushisp,
                               hushrs = hushrs,
                               kidge6 = kidge6,
                               age = age,
                               black = black,
                               educ = educ,
                               hispanic = hispanic,
                               union = union,
                               exper = exper,
                               kidlt6 = kidlt6))

our_pred_dummies <- predict(dummies, newdata = our_pred)
our_pred_matrix <- as.matrix(our_pred_dummies)

# Predição Elastic Net
predict_our_elastic <- predict(elastic_reg, our_pred_matrix)
antilog_pred_elastic <- exp(predict_our_elastic)
s_elastic <- sd(predictions_train_elastic - y_train)
dam_elastic <- s_elastic / sqrt(nrow(train))
CIlwr_elastic <- predict_our_elastic + qnorm(0.025) * dam_elastic
CIupr_elastic <- predict_our_elastic - qnorm(0.025) * dam_elastic
cat("\n--- Elastic Net ---\n")
cat("Predição salário-hora:", round(antilog_pred_elastic, 2), "\n")
cat("IC 95%: [", round(exp(CIlwr_elastic), 2), ", ", round(exp(CIupr_elastic), 2), "]\n")

