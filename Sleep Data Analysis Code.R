#Install and loading packages: tree, rpart, randomForest, ISLR
library(tree) 
library(rpart) 
library(randomForest) 
library(ISLR) 
library(pROC)
library(gam)


source("C://Users//shrey//OneDrive//Desktop//Data 101//hw//Errorfunction.R")
Sleep <- read.csv(col_types = cols(index = col_skip(), 
                                   Period = col_skip(), Activity = col_skip()),
                  colClasses = c("numeric", "factor", "factor", "numeric", "numeric", "factor", "factor","factor","factor"))
View(Sleep)
names(Sleep)[names(Sleep) == "Avg.hrs.per.day.sleeping"] <- "AvgHours"
head(Sleep) 

#Create new columns  
Sleep$Day <- with(Sleep, ifelse(Type.of.Days == 'All days', '1',
                                ifelse(Type.of.Days == 'Nonholiday weekdays', '2', '3')))
Sleep$Age <- with(Sleep, ifelse(Age.Group == '15 years and over', '1',
                                ifelse(Age.Group == '15 to 24 years', '2', 
                                       ifelse(Age.Group == '25 to 34 years', '3', 
                                              ifelse(Age.Group == '35 to 44 years', '4',
                                                     ifelse(Age.Group == '45 to 54 years', '5',
                                                            ifelse(Age.Group == '55 to 64 years', '6', '7'
                                                            )))))))
Sleep$Gender <- with(Sleep, ifelse(Sex == 'Men', '0',
                                   ifelse(Sex == 'Women', '1', '2')))
#Change the data to numeric
Sleep$Year <- as.numeric(Sleep$Year)
Sleep$Day <- as.numeric(Sleep$Day)
Sleep$Age <- as.factor(Sleep$Age)
Sleep$Gender <- as.numeric(Sleep$Gender)

# ANOVA Testing
#Hypothesis 1:
#H0: Each age group has the same average sleep time
#H1: Each age group has a different average sleep time
one.way <- aov(AvgHours ~ Age.Group, data = Sleep)
summary(one.way)
#             Df Sum Sq Mean Sq F value Pr(>F)    
#Age.Group     6  100.8  16.793   87.68 <2e-16 ***
#Residuals   938  179.6   0.192                   
#---
#Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#We reject H0 since all of the F values are significant, which means all of the means are different. #We conclude that each age group has a different average sleep time.

#Put here just in case
#all.way <- aov(AvgHours ~ Year + Age.Group + Type.of.Days + Sex, data = Sleep)
#summary(all.way)
#              Df Sum Sq Mean Sq F value Pr(>F)    
#Year           1   6.05    6.05   215.0 <2e-16 ***
#Age.Group      6 100.76   16.79   596.5 <2e-16 ***
#Type.of.Days   2 143.80   71.90  2554.1 <2e-16 ***
#Sex            2   3.52    1.76    62.6 <2e-16 ***
#Residuals    933  26.26    0.03                   
#---
#Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1


pairwise.t.test(Sleep$AvgHours, Sleep$Age.Group, p.adjust.method = "bonferroni", paired = TRUE)

#	Pairwise comparisons using paired t tests 

#data:  Sleep$AvgHours and Sleep$Age.Group 

#                  15 to 24 years 15 years and over 25 to 34 years
#15 years and over < 2e-16        -                 -             
#25 to 34 years    < 2e-16        1.00000           -             
#35 to 44 years    < 2e-16        < 2e-16           < 2e-16       
#45 to 54 years    < 2e-16        < 2e-16           < 2e-16       
#55 to 64 years    < 2e-16        < 2e-16           < 2e-16       
#65 years and over < 2e-16        3.2e-07           7.1e-05       
#                  35 to 44 years 45 to 54 years 55 to 64 years
#15 years and over -              -              -             
#25 to 34 years    -              -              -             
#35 to 44 years    -              -              -             
#45 to 54 years    4.9e-13        -              -             
#55 to 64 years    0.00041        1.00000        -             
#65 years and over < 2e-16        < 2e-16        < 2e-16       

#P value adjustment method: bonferroni


library(dplyr)

Sleep1<-Sleep%>%
  filter(!is.na(Sleep$AvgHours)&!is.na(Sleep$Age.Group))
#Checking which age group has highest mean 
Sleephravg<-tapply(Sleep$AvgHours,Sleep$Age.Group,mean)

barplot(Sleephravg, main="Average Hours of sleep by Age groups", font.main=4, col.main="purple", xlim=c(0,9), ylim=c(0, 15), xlab="Age group", ylab="Average sleep", las=2)


#Older less than young

#Hypothesis 2: 
#H0: The elder age group (>65) has the greatest average sleep time than other age groups

#H1: The elder age group (>65) do not have the greatest average sleep time among other age groups


#Compare the difference of mean between each significant age groups
fit_AvgSleep<-aov(Sleep$AvgHours~Sleep$Age.Group)
TukeyHSD(fit_AvgSleep)
# As 15-24 years tend to sleep more than 45-54 years by 1.01518519. Hence, we reject H0 and conclude that 45-54 years old sleep less than the 15-24 years.

#So, the average sleep of 65 years is greater than that of other groups except the group of 15 to 24 years

#Can try to test using Bonferroni Correction which of the older age groups in significantly different:



#Under Bonferroni hypothesis 
#1 test: 
#Our hypothesis: Average sleep hours for 45-54 age group are higher than Average sleep hours for 65 and above age group.
#Null hypothesis: There is no difference in sleep hours for 45-54 age group and Average sleep hours for 65 and above age group.

A<- subset(Sleep,  Sleep$Age.Group == "45 to 54 years")
A
B<- subset(Sleep, Sleep$Age.Group == "65 years and over")
B

#Calculating z-score:
A_explore<- explore(na.omit(A$AvgHours))
View(A_explore)
B_explore <- explore(na.omit(B$AvgHours))
View(B_explore)


sd_mix <- sqrt((A_explore[3])^2/A_explore[4] + (B_explore[3])^2/B_explore[4])
zeta <-(B_explore[1]-A_explore[1])/sd_mix
zeta

#Calculate p-value:
p_value <- 1 - pnorm(zeta)
p_value

#In this case, after applying Bonferroni Correction we get the value of the significance level= 0.05/(7*6/2) =  0.002380952
#Here, we get the p-value of 0 which is lower than the value of our 0.002380952.
#Based on this we reject our null hypothesis and so we can conclude that average sleep hours for 45-54 age group are higher than Average sleep hours for 65 and above age group.



#Test 2:
#Our hypothesis: Average sleep hours for 45-54 age group are higher than Average sleep hours for 65 and above age group.
#Null hypothesis: There is no difference in sleep hours for 45-54 age group and Average sleep hours for 65 and above age group.

A<- subset(Sleep,  Sleep$Age.Group == "45 to 54 years")
A
B<- subset(Sleep, Sleep$Age.Group == "65 years and over")
B

#Calculating z-score:
A_explore<- explore(na.omit(A$AvgHours))
View(A_explore)
B_explore <- explore(na.omit(B$AvgHours))
View(B_explore)


sd_mix <- sqrt((A_explore[3])^2/A_explore[4] + (B_explore[3])^2/B_explore[4])
zeta <-(B_explore[1]-A_explore[1])/sd_mix
zeta

#Calculate p-value:
p_value <- 1 - pnorm(zeta)
p_value

#In this case, after applying Bonferroni Correction we get the value of the significance level= 0.05/(7*6/2) =  0.002380952
#Here, we get the p-value of 0 which is lower than the value of our 0.002380952.
#Based on this we reject our null hypothesis and so we can conclude that average sleep hours for 45-54 age group are higher than Average sleep hours for 65 and above age group.







#LEAPS, MPSE, CP:
library(ISLR)
library(leaps)
library(lars)

#Creating a Second Order Matrix:
matrix.2ndorder.make<-function(x, only.quad=F){
  x0<-x
  dimn<-dimnames(x)[[2]] #extract the names of the variables
  num.col<-length(x[1,]) # how many columns
  for(i in 1:num.col){
    # if we are doing all 2nd order
    if(!only.quad){
      for(j in i:num.col){
        x0<-cbind(x0,x[,i]*x[,j])
        dimn<-c(dimn,paste(dimn[i],dimn[j],sep=""))
        #create interaction dimnames
      }
    }
    else{
      #in here only if doing only squared terms
      x0<-cbind(x0,x[,i]*x[,i])
      dimn<-c(dimn,paste(dimn[i],"2",sep="")) # squared dim names
    }
  }
  dimnames(x0)[[2]]<-dimn
  x0
}
x.sleep2<-matrix.2ndorder.make(Sleep)

regpluspress<-function(x,y){
  #Set str as lsfit that is used to get the least square estimate of beta in model: Y=beta*X+error. lsfit uses x as matrix whose rows correspond to cases and whose columns correspond to variables and y as the responses.
  str<-lsfit(x,y)
  #Set press as the PRESS function 
  press<-PRESS(x,y)
  str$press<-press
  str
}

#Press function
PRESS<-function(x,y){
  #Set ls.str as the least squares estimate  of beta, using 
  ls.str<-lsfit(x,y)
  #
  press<-sum((ls.str$resid/hat(x))^2)
  press
}

#Define the function using x-matrix, y-vectors, and checks 4 times
leaps.then.press.function=function(xmat,yvec,ncheck=4,print.ls=F)
{
  #Using leaps function to find the best subset of the variable xmat and yvec in linear regression
  leaps.str<-leaps(xmat,yvec)
  #Define z1 as leaps.str$Cp
  z1<-leaps.str$Cp
  #Arranges z1 in ascending order and defines it as o1
  o1<-order(z1)
  #Takes o1 from leaps.str from counts 1 to 10 and assigns to matwhich 
  matwhich<-(leaps.str$which[o1,])[1:ncheck,]
  #Assigns z2 from z1 counts from 1 to 10
  z2<-z1[o1][1:ncheck]
  #Starting a for loop, runs 10 times
  for(i in 1:ncheck){
    
    #Set ls.str0 that uses the regpluspress function with xmat's column matwhich's i th row and the yvec.
    ls.str0<-regpluspress(xmat[,matwhich[i,]],yvec)
    pred<-xmat[,matwhich[i,]]%*%ls.str0$coef[-1]+ls.str0$coef[1]
    
    #Prediction plot using leaps:
    pred.plot<-plot(pred, yvec)
    
    #Find coefficients for all 4 runs separately and all together then compare them in write up:
    #Print 
    print(ls.str0$coef)
    
    if(print.ls){
      ls.print(ls.str0) }
    
    print(i)
    #Print Press and concatenates them into one element
    print(paste("Press=",ls.str0$press))
    #Set parvec as the i th row of matwich
    parvec<-matwhich[i,]
    #Set npar as the sum of parvec
    npar<-sum(parvec)
    #Print MPSE and concatenates them into one element
    print(paste("MPSE=",ls.str0$press/(length(yvec)-(npar+1))))
    #Print Cp and concatenates them into one element. Error: it mentions Cp-p should be Cp.
    print(paste("Cp=",z2[i]))
    #Print the prediction plot
    print(pred.plot)
  }
}

Sleep.mat<-as.matrix(Sleep[,c(2,4,10,11,12)])
Sleep.mat[1:5,]

y.sleep<-Sleep.mat[,2]
x.sleep<-Sleep.mat[,c(-2)]
x.sleep2 <- matrix.2ndorder.make(x.sleep)

leaps.then.press.function(x.sleep2,Sleep.mat[,2])


#LEAPS prediction plots
#Group 54-65 years  
leaps.then.press.function(dumleaps.auto,Auto.mat[,1])

#Group 15-24 years  
leaps.then.press.function(dumleaps.auto,Auto.mat[,1])


#CV.LARS
cv.lars(x.sleep2,y.sleep)


#Response sleep, predictors: Age,  (fIlter out 55-64 and 15-24)

#Train and test dataset 
#n1<-length(Sleep[,1])
#v1<- sample(945, floor(3*n1/4), replace=T)
#Sleep.train<-Sleep[v1,]
#Sleep.test<-Sleep[-v1,]
#-----------------------------------
  #split your dataset
  #set.seed(1) # for reproducible
  # training dataset
  #split.per = 0.8
  #sample <- sample(c(TRUE, FALSE), nrow(Sleep), replace=TRUE, prob=c(split.per,1-split.per))
  #testing dataset
  #Sleep.test <- Sleep[!sample,]
  #train dataset
  #Sleep.train<- Sleep[sample,]
  
  

#testing dataset
Sleep.test2 <- subset(Sleep, (Sleep$Age.Group=="65 years and over") & Sleep$Year!=2017)
#training dataset
Sleep.train2<- subset(Sleep, (Sleep$Age.Group=="65 years and over") & Sleep$Year==2017)

#Do not use rank or Age, Gender in the models.
model<- lm(AvgHours ~ Age.Group+ Sex+ Type.of.Days + Year, data=Sleep.test1)
model.predict1<- predict(model, Sleep.train1)
Predicted1<- data.frame(model.predict1)
write.csv(Predicted1,file="Avg.sleep.hours1.csv")
regr.error(Predicted1$model.predict1, Sleep.test1$AvgHours)


model1<- lm(AvgHours ~ Sex + Year + Age.Group+ Age.Group:Sex + Type.of.Days:Sex + Year:Age.Group + Year:Type.of.Days, data=Sleep.test1)
model.predict2<- predict(model1, Sleep.train1)
Predicted2<- data.frame(model.predict2)
write.csv(Predicted2,file="Avg.sleep.hours2.csv")
regr.error(Predicted2$model.predict2, Sleep.test1$AvgHours)


#Lowest rmse means better prediction values for Avg Sleep Hours. Check other models with various predictors.

model2<- lm(AvgHours ~ Sex + Year + Age.Group+ Age.Group:Sex + Type.of.Days:Sex + Year:Age.Group + Year:Type.of.Days +Year:Sex, data=Sleep.test1)
model.predict3<- predict(model2, Sleep.train1)
Predicted3 <- data.frame(model.predict3)
write.csv(Predicted3,file="Avg.sleep.hours.predictions3.csv")
regr.error(Predicted3$model.predict3, Sleep.test1$AvgHours)

BIC(model)
BIC(model1)

#       mae        mse       rmse       mape 
#0.35804478 0.18305519 0.42784950 0.04052134 

k<-ols_step_all_possible(model1,sbc=TRUE)
plot(k)





rmsetest<-function(mod,datset){
  model.predict<-predict(mod,datset)
  Predicted<-data.frame(model.predict)
  regr.error(model.predict,datset$AvgHours)
}

model<- lm(AvgHours ~ Age.Group+ Sex+ Type.of.Days + Year, data=Sleep.test)
write.csv(Predicted,file="Avg.sleep.hours.predictions.csv")
rmsetest(model, Sleep.test)   
#       mae           mse       rmse       mape 
#0.12235652 0.02688501 0.16396648 0.01380462 

model1<- lm(AvgHours ~ Sex + Year + Age.Group+ Age.Group:Sex + Type.of.Days:Sex + Year:Age.Group + Year:Type.of.Days, data=Sleep.test)
write.csv(Predicted,file="Avg.sleep.hours.predictions1.csv")
rmsetest(model1,Sleep.test)   #0.15624505
#        mae        mse       rmse       mape 
#0.11433393 0.02441251 0.15624505 0.01287740 

model2<- lm(AvgHours ~ Sex + Year + Age.Group+ Age.Group:Sex + Type.of.Days:Sex + Year:Age.Group + Year:Type.of.Days +Year:Sex, data=Sleep.test)
write.csv(Predicted,file="Avg.sleep.hours.predictions2.csv")
rmsetest(model2,Sleep.test)  
#       mae        mse       rmse       mape 
#0.11400290 0.02432952 0.15597924 0.01283805 

#Lowest rmse means better prediction values for Avg Sleep Hours. Check other models with various predictors.


#Tree from the hw
library(tree) 
library(rpart) 
library(randomForest) 
library(ISLR) 
library(pROC)
library(gam)
dim(Sleep)
#[1] 945   9
dum0tree<-tree(AvgHours ~ Age.Group+ Sex + Type.of.Days + Year,data=Sleep.train)
dum0rpart<-rpart(AvgHours ~  Year + Age.Group+ Sex + Type.of.Days ,data=Sleep.train) 
rpart.plot(dum0rpart, type=5)
printcp(dum0rpart)#look at the rel error for other reg models to check which model gives lowest 

#Output:
#Regression tree:
#rpart(formula = AvgHours ~ Year + Age.Group + Type.of.Days + Sex, data = Sleep.train)

#Variables actually used in tree construction:
#[1] Age.Group    Type.of.Days

#Root node error: 203.04/708 = 0.28678

#n= 708 

#        CP nsplit rel error  xerror      xstd
#1 0.463240      0  1.000000 1.00305 0.0558210
#2 0.213491      1  0.536760 0.53973 0.0313555
#3 0.120772      2  0.323268 0.32631 0.0238954
#4 0.037632      3  0.202497 0.20480 0.0097879
#5 0.020802      4  0.164864 0.16732 0.0078902
#6 0.019024      5  0.144062 0.15225 0.0077357
#7 0.015024      6  0.125038 0.12738 0.0070034
#8 0.011862      7  0.110014 0.11590 0.0064808
#9 0.010000      8  0.098152 0.10430 0.0058100

dum0forest<-randomForest(AvgHours ~ Year + Age.Group + Type.of.Days + Sex, data=Sleep.train, importance=T, proximity=T)
par(mfrow=c(1,1))
plot(dum0forest)
dum0forest
Test50_rf_pred <- predict(dum0forest, Sleep.test, type="class")
table(Test50_rf_pred, Sleep.train$Creditability)
importance(dum0forest)
varImpPlot(dum0forest,  main="", cex=0.8)


rf50 <- randomForest(Creditability ~., data = Train50, ntree=200, importance=T, proximity=T)
plot(rf50, main="")
rf50
Test50_rf_pred <- predict(rf50, Test50, type="class")
table(Test50_rf_pred, Test50$Creditability)
importance(rf50)
varImpPlot(rf50,  main="", cex=0.8)




Sleeptree<-predict(dum0tree, newdata=Sleep.test) 
par(mfrow=c(1,1))
plot(dum0tree)
text(dum0tree)
Sleeprpart<-predict(dum0rpart,newdata=Sleep.test) 
par(mfrow=c(1,1))
plot(dum0rpart)
text(dum0rpart)
Sleep.train.model<-glm(AvgHours ~ Year + Age.Group + Type.of.Days + Sex,family=binomial(link=logit),Sleep.train)



#Errorfunction.R (source)
#Custom error function

#Custom error function
regr.error <- function(predicted,actual){
  #MSE
  mse <- mean((actual-predicted)^2)
  #RMSE
  rmse <- sqrt(mean((actual-predicted)^2))
  errors <- c(mse,rmse)
  names(errors) <- c("mse","rmse")
  return(errors)
}
regr.error(model.predict, Sleep.test$AvgHours)

#ASK: do we use rmse for accuracy of prediction or roc?

#Correlation test 
Sleep$Year <- as.numeric(Sleep$Year)
cor.test(Sleep$`Avg hrs per day sleeping`, Sleep$Year,
                   alternative = c("two.sided", "less", "greater"),
                   method = c("pearson", "kendall", "spearman"),
                   exact = NULL, conf.level = 0.95, continuity = FALSE)


 
Sleep1 <- subset(Sleep, Sleep$`Age Group` == "15 to 24 years")
cor.test(Sleep1$`Avg hrs per day sleeping`, Sleep1$Year,
alternative = c("two.sided", "less", "greater"),
        method = c("pearson", "kendall", "spearman"),
        exact = NULL, conf.level = 0.95, continuity = FALSE)


Sleep2 <- subset(Sleep, Sleep$`Age Group` == "15 years and over")
cor.test(Sleep2$`Avg hrs per day sleeping`, Sleep2$Year,
                    alternative = c("two.sided", "less", "greater"),
                    method = c("pearson", "kendall", "spearman"),
                  exact = NULL, conf.level = 0.95, continuity = FALSE)




Sleep3 <- subset(Sleep, Sleep$`Age Group` == "25 to 34 years")
cor.test(Sleep3$`Avg hrs per day sleeping`, Sleep3$Year,
      alternative = c("two.sided", "less", "greater"),
        method = c("pearson", "kendall", "spearman"),
        exact = NULL, conf.level = 0.95, continuity = FALSE)



Sleep4 <- subset(Sleep, Sleep$`Age Group` == "35 to 44 years")
cor.test(Sleep4$`Avg hrs per day sleeping`, Sleep4$Year,
                alternative = c("two.sided", "less", "greater"),
                    method = c("pearson", "kendall", "spearman"),
                   exact = NULL, conf.level = 0.95, continuity = FALSE)


Sleep <- stan_glm(AvgHours~ Sex + Year + Age.Group + Age.Group:Gender + Day:Gender + Year:Age. + Year:Day, family = "gaussian", data = Sleep.test,
                  prior_intercept = normal(0, 2.5, autoscale = TRUE),
                  prior = normal(0, 2.5, autoscale = TRUE), 
                  prior_aux = exponential(1, autoscale = TRUE),
                  chains = 4, iter = 5000*2, seed = 84735)

set.seed(84735)
prediction7 <- posterior_predict(
  Sleep, newdata = data.frame(Year = 2017, Age = 1, Sex=0))
colMeans(prediction7)


 
Sleep5 <- subset(Sleep, Sleep$`Age Group` == "45 to 54 years")
cor.test(Sleep5$`Avg hrs per day sleeping`, Sleep5$Year,
         alternative = c("two.sided", "less", "greater"),
         method = c("pearson", "kendall", "spearman"),
         exact = NULL, conf.level = 0.95, continuity = FALSE)


Sleep6 <- subset(Sleep, Sleep$`Age Group` == "55 to 64 years")
cor.test(Sleep6$`Avg hrs per day sleeping`, Sleep6$Year,
                 alternative = c("two.sided", "less", "greater"),
                 method = c("pearson", "kendall", "spearman"),
                 exact = NULL, conf.level = 0.95, continuity = FALSE)


Sleep7 <- subset(Sleep, Sleep$`Age Group` == "65 years and over")
cor.test(Sleep7$`Avg hrs per day sleeping`, Sleep7$Year,
         alternative = c("two.sided", "less", "greater"),
        method = c("pearson", "kendall", "spearman"),
         exact = NULL, conf.level = 0.95, continuity = FALSE)


sub1<-subset(Sleep, Sleep$Year<2005)
sub2<-subset(Sleep, Sleep$Year>2015)
cor.test(x=sub1$AvgHours, y=sub2$Age)


#Under Bonferroni hypothesis 2 test: 
#Our hypothesis: Average sleep hours for 45-54 age group are higher than Average sleep hours for 65 and above age group.
#Null hypothesis: There is no difference in sleep hours for 45-54 age group and Average sleep hours for 65 and above age group.

A<- subset(Sleep,  Sleep$Age.Group == "45 to 54 years")
A
B<- subset(Sleep, Sleep$Age.Group == "65 years and over")
B

#Calculating z-score:
A_explore<- explore(na.omit(A$AvgHours))
View(A_explore)
B_explore <- explore(na.omit(B$AvgHours))
View(B_explore)


sd_mix <- sqrt((A_explore[3])^2/A_explore[4] + (B_explore[3])^2/B_explore[4])
zeta <-(B_explore[1]-A_explore[1])/sd_mix
zeta

#Calculate p-value:
p_value <- 1 - pnorm(zeta)
p_value

#In this case, after applying Bonferroni Correction we get the value of the significance level= 0.05/(7*6/2) =  0.002380952
#Here, we get the p-value of 0 which is lower than the value of our 0.002380952.
#Based on this we reject our null hypothesis and so we can conclude that there is no difference in Average Average OCD levels after listening to Latin and the Average OCD levels after listening to EDM.




#Our hypothesis: Average sleep hours for 15-24 age group are higher than Average sleep hours for 65 and above age group.
#Null hypothesis: There is no difference in sleep hours for 15-24 age group and Average sleep hours for 65 and above age group.

A<- subset(Sleep,  Sleep$Age.Group == "15 to 24 years")
A
B<- subset(Sleep, Sleep$Age.Group == "35 to 44 years")
B

#Calculating z-score:
A_explore<- explore(na.omit(A$AvgHours))
View(A_explore)
B_explore <- explore(na.omit(B$AvgHours))
View(B_explore)


sd_mix <- sqrt((A_explore[3])^2/A_explore[4] + (B_explore[3])^2/B_explore[4])
zeta <-(B_explore[1]-A_explore[1])/sd_mix
zeta

#Calculate p-value:
p_value <- 1 - pnorm(zeta)
p_value

#In this case, after applying Bonferroni Correction we get the value of the significance level= 0.05/(7*6/2) =  0.002380952
#Here, we get the p-value of 0 which is lower than the value of our 0.002380952.
#Based on this we reject our null hypothesis and so we can conclude that there is no difference in Average Average OCD levels after listening to Latin and the Average OCD levels after listening to EDM.


#If still want to do trees do it 

BIC(model3)


#Data visualizations:


##Data Vizualization:
#creating piechart to see counts of music listeners of various Primary streaming services given.
S1 <-  Sleep %>% 
    filter((Age.Group=="15 to 24 years") & (AvgHours>9.5)&(Year>2009))

table(S1$Type.of.Days)
slices <- c(24, 15, 24)
lbl<- c("All days" , "Nonholiday weekdays", "Weekend days and holidays")
pie(slices, labels = lbl, main="Pie Chart of type of days when the 15 to 24 years sleep more than 9 hours in last 10 years ", col = wes_palette("FantasticFox1", 2, type = "continuous")) 


#Double bar plot of Two Age Groups Average Hours of sleep per day in three chosen years:
S3 <- Sleep %>% 
  filter((Age.Group=="15 to 24 years" | Age.Group=="55 to 64 years") & (Year==2003 | Year==2010| Year==2017))

ggplot(S3, aes(x = as.character(Year), y = AvgHours, fill = Age.Group)) +
  geom_col(position = position_dodge())+
  ggtitle("Two Age Groups Average Hours of sleep per day in three years")+ xlab("Year")


#Stacked bar plot:
S6 <- Sleep %>% 
  filter((Age.Group=="15 to 24 years"| Age.Group=="65 years and over") & AvgHours<9)

ggplot(S5, aes(x=Age.Group, fill=Type.of.Days, color=Type.of.Days))+
  geom_bar(position="identity")+ ggtitle("Frequency of two age group sleeping less than 9 hours in 2005")



#Stacked bar plot:
S5 <- Sleep %>% 
  filter((Age.Group=="15 to 24 years"| Age.Group=="65 years and over") & AvgHours<9 &Year==2015)

ggplot(S5, aes(x=Age.Group, fill=Type.of.Days, color=Type.of.Days))+
  geom_bar(position="identity")+ ggtitle("Frequency of two age group sleeping less than 9 hours in 2015")





#Stacked bar plot:
S5 <- Sleep %>% 
  filter((Age.Group=="15 to 24 years") &Year>2009)

ggplot(S5, aes(x=Age.Group, fill=Sex, color=Sex))+
  geom_bar(position="identity")+ ggtitle("Frequency of two age group sleeping less than 9 hours in 2015")


#A jitter plot of Average hours of sleep taken by people of 15 to 24 years age in various Type of days through various years.

ggplot(S5, aes(x = AvgHours, y = Year, color = Type.of.Days)) +
  geom_jitter(height = 0.25)+
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5))

ggplot(S5, aes(x = as.character(Year), y = AvgHours, color = Type.of.Days)) +
  geom_point()

ggplot(Slee, aes(x=Age.Group, fill=Type.of.Days, color=Type.of.Days))+
  geom_bar(position="identity")+ ggtitle("Frequency of two age group sleeping less than 9 hours in 2005")




#Stacked bar plot:
Slee <- Sleep5%>%
 filter((Age.Group=="15 to 24 years"| Age.Group=="65 years and over")& (AvgHours<9))


ggplot(Slee, aes(x = Year, y =as.character(Age.Group), color = AvgHours)) +
  geom_jitter(height = 0.25)


Sleep <- stan_glm(AvgHours ~ Gender + Year + Age + Age:Gender + Day:Gender + Year:Age + Year:Day, family = "gaussian", data = Sleep.test,
                  prior_intercept = normal(0, 2.5, autoscale = TRUE),
                  prior = normal(0, 2.5, autoscale = TRUE), 
                  chains = 4, iter = 5000*2, seed = 84735)
set.seed(84735)

prediction1 <- posterior_predict(
  Sleep, newdata = data.frame(Year = 2017, Age = 2, Gender = 0, Day = 1 ))
table(prediction1)
colMeans(prediction1)



M<- cor(Sleep)
corrplot(M, method = 'color', order = 'alphabet')



rmsetest<-function(mod,datset){
  model.predict<-predict(mod,Sleep.train)
  predicted3<-data.frame(model.predict)
  regr.error(predicted$model.predict,datset$AvgHours)
  #write.csv(predicted,file="SleepPred.csv")
}
write.csv(Predicted3,file="Avg.sleep.hours.predictionsr.csv")
rmsetest(model, Sleep.test)  


k<-ols_step_all_possible(model2,sbc=TRUE)




#Creating a Second Order Matrix:
matrix.2ndorder.make<-function(x, only.quad=F){
  x0<-x
  dimn<-dimnames(x)[[2]] #extract the names of the variables
  num.col<-length(x[1,]) # how many columns
  for(i in 1:num.col){
    # if we are doing all 2nd order
    if(!only.quad){
      for(j in i:num.col){
        x0<-cbind(x0,x[,i]*x[,j])
        dimn<-c(dimn,paste(dimn[i],dimn[j],sep=""))
        #create interaction dimnames
      }
    }
    else{
      #in here only if doing only squared terms
      x0<-cbind(x0,x[,i]*x[,i])
      dimn<-c(dimn,paste(dimn[i],"2",sep="")) # squared dim names
    }
  }
  dimnames(x0)[[2]]<-dimn
  x0
}
x.sleep2<-matrix.2ndorder.make(Sleep)

regpluspress<-function(x,y){
  #Set str as lsfit that is used to get the least square estimate of beta in model: Y=beta*X+error. lsfit uses x as matrix whose rows correspond to cases and whose columns correspond to variables and y as the responses.
  str<-lsfit(x,y)
  #Set press as the PRESS function 
  press<-PRESS(x,y)
  str$press<-press
  str
}

#Press function
PRESS<-function(x,y){
  #Set ls.str as the least squares estimate  of beta, using 
  ls.str<-lsfit(x,y)
  #
  press<-sum((ls.str$resid/hat(x))^2)
  press
}

#Define the function using x-matrix, y-vectors, and checks 4 times


leaps.then.press.function=function(xmat,yvec,ncheck=4,print.ls=F)
{
  #Using leaps function to find the best subset of the variable xmat and yvec in linear regression
  leaps.str<-leaps(xmat,yvec)
  #Define z1 as leaps.str$Cp
  z1<-leaps.str$Cp
  #Arranges z1 in ascending order and defines it as o1
  o1<-order(z1)
  #Takes o1 from leaps.str from counts 1 to 10 and assigns to matwhich 
  matwhich<-(leaps.str$which[o1,])[1:ncheck,]
  #Assigns z2 from z1 counts from 1 to 10
  z2<-z1[o1][1:ncheck]
  #Starting a for loop, runs 10 times
  for(i in 1:ncheck){
    
    #Set ls.str0 that uses the regpluspress function with xmat's column matwhich's i th row and the yvec.
    ls.str0<-regpluspress(xmat[,matwhich[i,]],yvec)
    pred<-xmat[,matwhich[i,]]%*%ls.str0$coef[-1]+ls.str0$coef[1]
    
    #Prediction plot using leaps:
    pred.plot<-plot(pred, yvec)
    
    #Find coefficients for all 4 runs separately and all together then compare them in write up:
    #Print 
    print(ls.str0$coef)
    
    if(print.ls){
      ls.print(ls.str0) }
    
    print(i)
    #Print Press and concatenates them into one element
    print(paste("Press=",ls.str0$press))
    #Set parvec as the i th row of matwich
    parvec<-matwhich[i,]
    #Set npar as the sum of parvec
    npar<-sum(parvec)
    #Print MPSE and concatenates them into one element
    print(paste("MPSE=",ls.str0$press/(length(yvec)-(npar+1))))
    #Print Cp and concatenates them into one element. Error: it mentions Cp-p should be Cp.
    print(paste("Cp=",z2[i]))
    #Print the prediction plot
    print(pred.plot)
  }
}

#LEAPS prediction plots
Sleep.mat<-as.matrix(Sleep[,c(1, 2,7,8,9)])
Sleep.mat[1:5,]
y.sleep<-Sleep.mat[,2]
x.sleep<-Sleep.mat[,c(-2)]
x.sleep2 <- matrix.2ndorder.make(x.sleep)
leaps.then.press.function(x.sleep2,Sleep.mat[,2])
leaps.then.press.function(x.sleep2,y.sleep)
pairs(Sleep.mat)


#Train and Test(other way)
#split your dataset
#testing dataset
Sleep.test1 <- subset(Sleep, (Sleep$Age.Group=="15 to 24 years") & Sleep$Year!=2017)
#training dataset
Sleep.train1<- subset(Sleep, (Sleep$Age.Group=="15 to 24 years") & Sleep$Year==2017)


rmsetest<-function(mod,datset){
  model.predict<-predict(mod,Sleep.train,type="response") #change to Sleep.train1 for subset
  predicted<-data.frame(model.predict)
  write.csv(predicted,file="SleepPred.csv")
  regr.error(model.predict,datset$AvgHours)
}

modelyy<- lm(AvgHours ~ Age.Group+ Sex+ Type.of.Days + Year, data=Sleep.test1)
write.csv(Predicted,file="Avg.sleep.hours.predictionsyoung.csv")
rmsetest(modelyy, Sleep.test1) 


model1<- lm(AvgHours ~ Sex + Year + Age.Group+ Age.Group:Sex + Type.of.Days:Sex + Year:Age.Group + Year:Type.of.Days, data=Sleep.test)
write.csv(Predicted,file="Avg.sleep.hours.predictions1young.csv")
rmsetest(model1,Sleep.test) 


model2<- lm(AvgHours ~ Sex + Year + Age.Group+ Age.Group:Sex + Type.of.Days:Sex + Year:Age.Group + Year:Type.of.Days +Year:Sex, data=Sleep.test)
write.csv(Predicted,file="Avg.sleep.hours.predictions2young.csv")
rmsetest(model2,Sleep.test)  
BIC(model)
BIC(model1)
BIC(model2)
