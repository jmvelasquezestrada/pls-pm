#Clear Environment
rm(list=ls())

#Creating Simulated Data
source("./thesis/simsem.R")

#Creating Model

#Load our Algorithms
source("./lib/simplePLS.R")
source("./lib/graphUtils.R")

#Seed to the random process
set.seed(123)


#Create the Matrix of the Structural Model
smMatrix <- matrix(c("LV1", "LV3",
                     "LV2","LV3"),nrow=2,ncol=2,byrow =TRUE,
                   dimnames = list(1:2,c("source","target")))

#Create the Matrix of the Measurement Model
mmMatrix <- matrix(c("LV1","x11","F",
                     "LV1","x12","F",
                     "LV1","x13","F",
                     "LV2","x21","F",
                     "LV2","x22","F",
                     "LV2","x23","F",
                     "LV3","x31","R",
                     "LV3","x32","R",
                     "LV3","x33","R",
                     "LV3","x34","R"),nrow=10,ncol=3,byrow =TRUE,
                   dimnames = list(1:10,c("latent","measurement","type")))

#Get the index for the Training and the test data
index=sample.int(dim(semData)[1],1000,replace=T)

#Obtain Train subsample
trainData <-semData[index,]

#Prepare container for data
plsPredictions<-matrix(nrow=300000, ncol=4, dimnames = list(1:300000,c("x31","x32","x33","x34")))

lowindex <- 1
highindex <- 0

#Bootstrap Cycle
for (i in 1:1000 ) {
  highindex <- i*300
  
  #Call PLS-PM Function
  plsModel<-simplePLS(trainData,smMatrix,mmMatrix)

  #Call Prediction Function
  predTest <- PLSpredict(plsModel,semData)
  
  #Put the predicitons in the 
  plsPredictions[(lowindex:highindex),] <- predTest$predictedMeasurements
  
  #Resample Again
  
  #Get the index for the Training and the test data
  index=sample.int(dim(semData)[1],1000,replace=T)
  
  #Obtain Train subsample
  trainData <-semData[index,]

  #Prepare the low index for next iteration
  lowindex <- highindex +1
  
}
  
plsPredictions


#Set the panels
par(mfrow=c(2,2))

x7<-plsPredictions[seq(from=1, to =300000, by = 300),1]
intX7<-quantile(x7,  probs = c(0.025,0.975))
meanx7<-mean (x7)

d <- density(x7) # returns the density data 
plot(d, main="Distribution 1st. Observation (X7)",xlab =  paste("Actual = ", round(semData[1,"x31"],3) ," Mean = ",round(meanx7,3)," 95% Confidence Prediction Interval = (",round(intX7[1],3),"<->",round(intX7[2],3),")" )) # plots the results
abline (v=meanx7)
abline (v=intX7[1])
abline (v=intX7[2])

plsPredictions[1:4,]
semData [1:4,]

x8<-plsPredictions[seq(from=1, to =300000, by = 300),2]
intX8<-quantile(x8,  probs = c(0.025,0.975))
meanx8<-mean (x8)

d <- density(x8) # returns the density data 
plot(d, main="Distribution 1st. Observation (X8)",xlab =  paste("Mean = ",round(meanx8,3)," 95% Confidence Prediction Interval = (",round(intX8[1],3),"<->",round(intX8[2],3),")" )) # plots the results
abline (v=meanx8)
abline (v=intX8[1])
abline (v=intX8[2])


intX7[1]
#Cycle for the k-fold analysis
size <- length(index)
n <- 10 
range <- floor(size/n)
lowindex <- 1
highindex <- 0
pls.predictedMeasurements<-semData [,c("x31","x32","x33","x34")]
lm.predictedMeasurements<-semData [,c("x31","x32","x33","x34")]


#Iterative process
for (i in seq(from=30, to =size, by = range) ) {
  highindex <- i
  
  #Get the training and the test data
  trainData=semData[-(lowindex:highindex),]
  testData=semData[(lowindex:highindex),]
  
  #Call PLS-PM Function
  plsModel<-simplePLS(trainData,smMatrix,mmMatrix,9)
  
  #Call Prediction Function
  predTest <- PLSpredict(plsModel,testData)
  
  #Put the predicitons in the 
  pls.predictedMeasurements[(lowindex:highindex),] <- predTest$predictedMeasurements
  
  #Multiple LInear Regeresion for each output variable
  lmX31 <- with(trainData, lm(x31 ~ x11+x12+x13+x21+x22+x23))
  lmX32 <- with(trainData, lm(x32 ~ x11+x12+x13+x21+x22+x23))
  lmX33 <- with(trainData, lm(x33 ~ x11+x12+x13+x21+x22+x23))
  lmX34 <- with(trainData, lm(x34 ~ x11+x12+x13+x21+x22+x23))
  
  #Use our custom function to predict each value for training data
  predTestX31 <- predictlm (lmX31,testData)
  predTestX32 <- predictlm (lmX32,testData)
  predTestX33 <- predictlm (lmX33,testData)
  predTestX34 <- predictlm (lmX34,testData)
  
  #Join the Predictions in vector
  predTestlm <- cbind(predTestX31,predTestX32,predTestX33,predTestX34)
  names(predTestlm)<-c("x31","x32","x33","x34")
  
  #Put the predicitons in the 
  lm.predictedMeasurements[(lowindex:highindex),] <- predTestlm
  
  #Prepare the low index for next iteration
  lowindex <- i +1
}


#Set the panels
par(mfrow=c(2,2))

#Find scales
xmax<-ceiling(max(c(semData[,"x31"],
                    semData[,"x32"],
                    semData[,"x33"],
                    semData[,"x34"])))

ymax<-ceiling(max(c(pls.predictedMeasurements[,"x31"],
                    pls.predictedMeasurements[,"x32"],
                    pls.predictedMeasurements[,"x33"],
                    pls.predictedMeasurements[,"x34"],
                    lm.predictedMeasurements[,"x31"],
                    lm.predictedMeasurements[,"x32"],
                    lm.predictedMeasurements[,"x33"],
                    lm.predictedMeasurements[,"x34"])))

xmin<-floor(min(c(semData[,"x31"],
                  semData[,"x32"],
                  semData[,"x33"],
                  semData[,"x34"])))

ymin<-floor(min(c(pls.predictedMeasurements[,"x31"],
                  pls.predictedMeasurements[,"x32"],
                  pls.predictedMeasurements[,"x33"],
                  pls.predictedMeasurements[,"x34"],
                  lm.predictedMeasurements[,"x31"],
                  lm.predictedMeasurements[,"x32"],
                  lm.predictedMeasurements[,"x33"],
                  lm.predictedMeasurements[,"x34"])))

#Actual vs Predicted (x31)
y<-pls.predictedMeasurements[,"x31"]
x<-semData[,"x31"]
z<-lm.predictedMeasurements[,"x31"]
title="Actual vs Predicted (X7)"
xlabel=paste("Means: Act=",
             signif(mean(x),digits=4),
             "PLS=",
             signif(mean(y),digits=4),
             "LM=",
             signif(mean(z),digits=4),
             "\n Standard Deviation: Act=",
             signif(sd(x),digits=4),
             "PLS=",
             signif(sd(y),digits=4),
             "LM=",
             signif(sd(z),digits=4))
ylabel="Predicted"
dualGraphScatterplot(x,y,z,title,xlabel,ylabel,xmax=xmax,ymax=ymax,xmin=xmin,ymin=ymin)

#Actual vs Predicted (x32)
y<-pls.predictedMeasurements[,"x32"]
x<-semData[,"x32"]
z<-lm.predictedMeasurements[,"x32"]
title="Actual vs Predicted (X8)"
xlabel=paste("Means: Act=",
             signif(mean(x),digits=4),
             "PLS=",
             signif(mean(y),digits=4),
             "LM=",
             signif(mean(z),digits=4),
             "\n Standard Deviation: Act=",
             signif(sd(x),digits=4),
             "PLS=",
             signif(sd(y),digits=4),
             "LM=",
             signif(sd(z),digits=4))
ylabel="Predicted"
dualGraphScatterplot(x,y,z,title,xlabel,ylabel,xmax=xmax,ymax=ymax,xmin=xmin,ymin=ymin)

#Actual vs Predicted (x33)
y<-pls.predictedMeasurements[,"x33"]
x<-semData[,"x31"]
z<-lm.predictedMeasurements[,"x33"]
title="Actual vs Predicted (X9)"
xlabel=paste("Means: Act=",
             signif(mean(x),digits=4),
             "PLS=",
             signif(mean(y),digits=4),
             "LM=",
             signif(mean(z),digits=4),
             "\n Standard Deviation: Act=",
             signif(sd(x),digits=4),
             "PLS=",
             signif(sd(y),digits=4),
             "LM=",
             signif(sd(z),digits=4))
ylabel="Predicted"
dualGraphScatterplot(x,y,z,title,xlabel,ylabel,xmax=xmax,ymax=ymax,xmin=xmin,ymin=ymin)

#Actual vs Predicted (x34)
y<-pls.predictedMeasurements[,"x34"]
x<-semData[,"x34"]
z<-lm.predictedMeasurements[,"x34"]
title="Actual vs Predicted (X10)"
xlabel=paste("Means: Act=",
             signif(mean(x),digits=4),
             "PLS=",
             signif(mean(y),digits=4),
             "LM=",
             signif(mean(z),digits=4),
             "\n Standard Deviation: Act=",
             signif(sd(x),digits=4),
             "PLS=",
             signif(sd(y),digits=4),
             "LM=",
             signif(sd(z),digits=4))
ylabel="Predicted"
dualGraphScatterplot(x,y,z,title,xlabel,ylabel,xmax=xmax,ymax=ymax,xmin=xmin,ymin=ymin)

#Set the panels
par(mfrow=c(2,2))

#Find scales
xmax<-ceiling(max(c(lm.predictedMeasurements[,"x31"],
                    lm.predictedMeasurements[,"x32"],
                    lm.predictedMeasurements[,"x33"],
                    lm.predictedMeasurements[,"x34"])))

ymax<-ceiling(max(c(pls.predictedMeasurements[,"x31"],
                    pls.predictedMeasurements[,"x32"],
                    pls.predictedMeasurements[,"x33"],
                    pls.predictedMeasurements[,"x34"])))

xmin<-floor(min(c(lm.predictedMeasurements[,"x31"],
                  lm.predictedMeasurements[,"x32"],
                  lm.predictedMeasurements[,"x33"],
                  lm.predictedMeasurements[,"x34"])))

ymin<-floor(min(c(pls.predictedMeasurements[,"x31"],
                  pls.predictedMeasurements[,"x32"],
                  pls.predictedMeasurements[,"x33"],
                  pls.predictedMeasurements[,"x34"])))

#PLS: LM vs PLS (x31)
y<-pls.predictedMeasurements[,"x31"]
x<-lm.predictedMeasurements[,"x31"]
title="LM vs PLS (X7)"
xlabel="Linear Model"
ylabel="PLS"
graphScatterplot42(x,y,title,xlabel,ylabel,xmax=xmax,ymax=ymax,xmin=xmin,ymin=ymin)

#PLS: LM vs PLS (x32)
y<-pls.predictedMeasurements[,"x32"]
x<-lm.predictedMeasurements[,"x32"]
title="LM vs PLS (X8)"
xlabel="Linear Model"
ylabel="PLS"
graphScatterplot42(x,y,title,xlabel,ylabel,xmax=xmax,ymax=ymax,xmin=xmin,ymin=ymin)

#PLS: LM vs PLS (x33)
y<-pls.predictedMeasurements[,"x33"]
x<-lm.predictedMeasurements[,"x33"]
title="LM vs PLS (X9)"
xlabel="Linear Model"
ylabel="PLS"
graphScatterplot42(x,y,title,xlabel,ylabel,xmax=xmax,ymax=ymax,xmin=xmin,ymin=ymin)

#PLS: LM vs PLS (x34)
y<-pls.predictedMeasurements[,"x34"]
x<-lm.predictedMeasurements[,"x34"]
title="LM vs PLS (X10)"
xlabel="Linear Model"
ylabel="PLS"
graphScatterplot42(x,y,title,xlabel,ylabel,xmax=xmax,ymax=ymax,xmin=xmin,ymin=ymin)

#Set the panels
par(mfrow=c(2,2))
xrange<-c(-4,4)
yrange<-c(0,0.8)
title<-"PLS and LM Prediction Errors"
xcolor=rgb(0.25,0.25,0.25,0.5)
ycolor=rgb(0,0,0,0.5)

lm.residuals <- semData [,c("x31","x32","x33","x34")] - lm.predictedMeasurements
pls.residuals <- semData [,c("x31","x32","x33","x34")] - pls.predictedMeasurements

graphCombinedResiduals("x31",lm.residuals,pls.residuals ,paste(title,"X7"),xrange,yrange,10,"LM","PLS",xcolor,ycolor)
graphCombinedResiduals("x32",lm.residuals,pls.residuals ,paste(title,"X8"),xrange,yrange,10,"LM","PLS",xcolor,ycolor)
graphCombinedResiduals("x33",lm.residuals,pls.residuals ,paste(title,"X9"),xrange,yrange,10,"LM","PLS",xcolor,ycolor)
graphCombinedResiduals("x34",lm.residuals,pls.residuals ,paste(title,"X10"),xrange,yrange,10,"LM","PLS",xcolor,ycolor)
