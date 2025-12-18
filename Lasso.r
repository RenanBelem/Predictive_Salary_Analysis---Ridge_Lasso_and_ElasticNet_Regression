#carreragando trabalho
# Configurando ambiente
install.packages("plyr")
install.packages("readr")
install.packages("dplyr")
install.packages("caret")
install.packages("ggplot2")
install.packages("repr")
install.packages("glmnet")

#setwd("C:\\Users\\anava\\OneDrive\\Documentos\\MBA\\IAA-05")
load("trabalhosalarios.RData")
View(trabalhosalarios)
dt <- trabalhosalarios

#versao log 
lwage <- trabalhosalarios[, "lwage"]
lwage_notLog <- exp(lwage)

#Matriz de Correlacao
md_complete <- cor(trabalhosalarios, use="complete")
md_lwage <- md_complete[, c(which(colnames(md_complete) == "lwage"))]
print(md_lwage)


#Matriz de correlacao com Iwage

#      husage     husunion     husearns      huseduc      husblck      hushisp       hushrs       kidge6        earns          age 
# 0.087213182 -0.008449603  0.347453195  0.341303393 -0.030346899 -0.084764263 -0.011243474 -0.053192868  0.814948780  0.096366388 
#       black         educ     hispanic        union        exper       kidlt6        lwage 
#-0.038480407  0.443719054 -0.091003826  0.200631490 -0.019001336 -0.019925469  1.000000000 


#MQO - Iwage  l 
#Estimativa preliminar 
resultadoRegr <-lm(lwage~., data=trabalhosalarios)
summary(resultadoRegr)

lm(formula = lwage ~ ., data = trabalhosalarios)

#Residuals:
#    Min      1Q  Median      3Q     Max 
#-4.9480 -0.1218  0.0033  0.1230  1.7260 

#Coefficients:
#               Estimate Std. Error t value Pr(>|t|)    
# (Intercept) -7.572e-01  1.749e+00  -0.433 0.665135    
# husage       1.053e-03  1.308e-03   0.805 0.420637    
# husunion     5.850e-03  1.418e-02   0.412 0.680064    
# husearns     1.148e-04  2.000e-05   5.738 1.07e-08 ***
# huseduc      3.993e-03  2.791e-03   1.431 0.152612    
# husblck      3.238e-03  7.133e-02   0.045 0.963801    
# hushisp     -1.033e-02  4.076e-02  -0.253 0.799913    
# hushrs      -9.905e-04  4.567e-04  -2.169 0.030166 *  
# kidge6       1.896e-02  1.357e-02   1.397 0.162457    
# earns        1.611e-03  2.781e-05  57.948  < 2e-16 ***
# age          3.146e-01  2.915e-01   1.079 0.280532    
# black       -3.658e-02  7.229e-02  -0.506 0.612947    
# educ        -2.919e-01  2.915e-01  -1.001 0.316757    
# hispanic    -5.939e-02  3.889e-02  -1.527 0.126827    
# union        6.013e-02  1.703e-02   3.531 0.000421 ***
# exper       -3.140e-01  2.915e-01  -1.077 0.281451    
# kidlt6       7.148e-02  1.637e-02   4.365 1.32e-05 ***
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

print("variaveis que influenciamm na iwage *** 99.99 %")
print("husearns,earns, union, kidlt6")
#  * 95%
print("variaveis que influenciamm na iwage * 95 %")
print("hushrs")

# Residual standard error: 0.2909 on 2557 degrees of freedom
# Multiple R-squared:  0.6914,    Adjusted R-squared:  0.6894 
# F-statistic:   358 on 16 and 2557 DF,  p-value: < 2.2e-16
print("Residual standard error: 0.2909, Multiple R-squared:  0.6914,    Adjusted R-squared:  0.6894 ")

print("F-statistic: 358 on 16 and 2557 DF")
qnorm(0.975)
qf(0.95, 19, 521)
print("358 > 1.606536 - existe reta de regressao")
#t student testar beta - amostra pequena  
# Test F  existe reta de regressa
# teste z b - amostra grande 



#Fazer as regressões Ridge, Lasso e ElasticNet 
#log achata a variancia 

#Regressao de    Lasso 

library(plyr)
library(readr)
library(dplyr)
library(caret)
library(ggplot2)
library(repr)
library(glmnet)


glimpse(dt)

#dt$lwage <- (exp(trabalhosalarios[, "lwage"]))
#particionar dataset 
set.seed(302)  

d_indx = sample(1:nrow(dt),0.8*nrow(dt))

train = dt[d_indx,]  
test = dt[-d_indx,] 
dim(train)
dim(test)


#criar o dataset   baseada no resultado
dat_colB <- c('husage','husearns','hushisp','huseduc','hushrs','age','educ','exper','lwage')
pre_proc_val <- preProcess(train[,dat_colB], 
                           method = c("center", "scale"))
train[,dat_colB] = predict(pre_proc_val, train[,dat_colB])
test[,dat_colB] = predict(pre_proc_val, test[,dat_colB])

data_col <- c('husage','husunion','husearns','huseduc','hushrs','husblck', 'hushisp', 'kidge6','age','black','educ','hispanic','union','exper','kidlt6','lwage')

summary(train)
summary(test)
dummies <- dummyVars(lwage~husage+husunion+husearns+huseduc+husblck+husblck+hushisp+hushrs+
                        kidge6+age+black+educ+hispanic+union+exper+kidlt6,
                    data= dt[data_col])

train_dummies = predict(dummies, newdata = train[,data_col])
test_dummies = predict(dummies, newdata = test[,data_col])

#print(dim(train_dummies)); print(dim(test_dummies))
x = as.matrix(train_dummies)
y_train = train$lwage
x_test = as.matrix(test_dummies)
y_test = test$lwage

lambdas <- 10^seq(2, -3, by = -.1)
lasso_lamb <- cv.glmnet(x, y_train, alpha = 1, 
                        lambda = lambdas, 
                        standardize = TRUE, nfolds = 5)

best_lambda_lasso <- lasso_lamb$lambda.min 
print(best_lambda_lasso)



lasso_model <- glmnet(x, y_train, alpha = 1, 
                      lambda = best_lambda_lasso, 
                      standardize = TRUE)

lasso_model[["beta"]]

predictions_train <- predict(lasso_model, 
                             s = best_lambda_lasso,
                             newx = x)


eval_results <- function(true, predicted, df) {
  SSE <- sum((predicted - true)^2)
  SST <- sum((true - mean(true))^2)
  R_square <- 1 - SSE / SST
  RMSE = sqrt(SSE/nrow(df))

  data.frame(
    RMSE = RMSE,
    Rsquare = R_square
  )
}



eval_results(y_train, predictions_train, train)
print("Resultados no conjunto de treino:")

predictions_test <- predict(lasso_model, 
                            s = best_lambda_lasso, 
                            newx = x_test)


eval_results(y_test, predictions_test, test)
print("Resultados no conjunto de teste:")

#valores  para predizer 
husage = (40-pre_proc_val[["mean"]][["husage"]])/
  pre_proc_val[["std"]][["husage"]]
husunion = 0
husearns = (600-pre_proc_val[["mean"]][["husearns"]])/
  pre_proc_val[["std"]][["husearns"]]
huseduc = (13-pre_proc_val[["mean"]][["huseduc"]])/
  pre_proc_val[["std"]][["huseduc"]]
husblck = 1 
hushisp = 0 
hushrs = (40-pre_proc_val[["mean"]][["hushrs"]])/
  pre_proc_val[["std"]][["hushrs"]]
kidge6 = 0
age = (36-pre_proc_val[["mean"]][["age"]])/
  pre_proc_val[["std"]][["age"]]
black = 0
educ = (13-pre_proc_val[["mean"]][["educ"]])/
  pre_proc_val[["std"]][["educ"]]
hispanic = 1
union = 0
exper = (13-pre_proc_val[["mean"]][["exper"]])/
  pre_proc_val[["std"]][["exper"]]
kidlt6 = 0

our_pred = as.matrix(data.frame(husage=husage,
                                husunion=husunion,
                                husearns=husearns,
                                huseduc=huseduc,
                                husblck=husblck,
                                hushisp=hushisp,
                                hushrs=hushrs,
                                kidge6=kidge6,
                                age=age,
                                black=black,
                                educ=educ,
                                hispanic=hispanic,
                                union=union,
                                exper=exper,
                                kidlt6=kidlt6))


predict_our_lasso <- predict(lasso_model, 
                             s = best_lambda_lasso, 
                             newx = our_pred)
print(predict_our_lasso)




wage_pred_lasso=(predict_our_lasso*
                   pre_proc_val[["std"]][["lwage"]])+
  pre_proc_val[["mean"]][["lwage"]]
print(wage_pred_lasso)

resultado<- exp(wage_pred_lasso)
print(resultado)


n <- nrow(train)
m <- wage_pred_lasso
s <- pre_proc_val[["std"]][["lwage"]]
dam <- s/sqrt(n)
CIlwr_lasso <- m + (qnorm(0.025))*dam
CIupr_lasso <- m - (qnorm(0.025))*dam
# O intervalo de confianca eh:


print("Resultado  Inferior ")
print(CIlwr_lasso)
print("Resultado  Superior ")
print(CIupr_lasso)


