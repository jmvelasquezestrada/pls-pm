#Clear the Environment
rm(list=ls())

#Load our Algorithm
source("./lib/simplePLS.R")
source("./lib/graphUtils.R")

#Load Data
trainData=read.csv("./data/simTrain.csv",header=T)
holdData=read.csv("./data/simHoldout.csv",header=T)
nnPredData=read.csv("./data/simPred.csv",header=T)

#Calculate nn prediction residuals
nnPredResiduals<-holdData[,c("y1","y2","y3","y4")]-nnPredData[,c("y1","y2","y3","y4")]

#Create the Matrix of the Structural Model
smMatrix <- matrix(c("Latent Variable 1", "Latent Variable 3",
                     "Latent Variable 2","Latent Variable 3"),nrow=2,ncol=2,byrow =TRUE,
                   dimnames = list(1:2,c("source","target")))

#Create the Matrix of the Measurement Model
mmMatrix <- matrix(c("Latent Variable 1","x11","R",
                     "Latent Variable 1","x12","R",
                     "Latent Variable 1","x13","R",
                     "Latent Variable 1","x14","R",
                     "Latent Variable 2","x21","R",
                     "Latent Variable 2","x22","R",
                     "Latent Variable 2","x23","R",
                     "Latent Variable 2","x24","R",
                     "Latent Variable 3","y1","R",
                     "Latent Variable 3","y2","R",
                     "Latent Variable 3","y3","R",
                     "Latent Variable 3","y4","R"),nrow=12,ncol=3,byrow =TRUE,
                   dimnames = list(1:12,c("latent","measurement","type")))

#Call PLS-PM Function
plsModel<-simplePLS(trainData,smMatrix,mmMatrix)

#Call Prediction Function
predHold <- PLSpredict(plsModel,holdData)

#Set the panels
par(mfrow=c(2,2))

#Find scales
xmax<-ceiling(max(c(holdData[,"y1"],
                    holdData[,"y2"],
                    holdData[,"y3"],
                    holdData[,"y4"])))

ymax<-ceiling(max(c(predHold$predictedMeasurements[,"y1"],
                    predHold$predictedMeasurements[,"y2"],
                    predHold$predictedMeasurements[,"y3"],
                    predHold$predictedMeasurements[,"y4"])))

#PLS: Actual vs Predicted (y1)
y<-predHold$predictedMeasurements[,"y1"]
x<-holdData[,"y1"]
z<-nnPredData[,"y1"]
title="Actual vs Predicted (y1)"
xlabel=paste("Mean: Act=",
             signif(mean(x),digits=4),
             "PLS=",
             signif(mean(y),digits=4),
             "NN=",
             signif(mean(z),digits=4),
             "\n SD: Act=",
             signif(sd(x),digits=4),
             "PLS=",
             signif(sd(y),digits=4),
             "NN=",
             signif(sd(z),digits=4))
ylabel="Predicted"
graphScatterplot(x,y,z,title,xlabel,ylabel,xmax=xmax,ymax=ymax)
points(x,z, col= "black")

#PLS: Actual vs Predicted (y2)
y<-predHold$predictedMeasurements[,"y2"]
x<-holdData[,"y2"]
z<-nnPredData[,"y2"]
title="Actual vs Predicted (y2)"
xlabel=paste("Mean: Act=",
             signif(mean(x),digits=4),
             "PLS=",
             signif(mean(y),digits=4),
             "NN=",
             signif(mean(z),digits=4),
             "\n SD: Act=",
             signif(sd(x),digits=4),
             "PLS=",
             signif(sd(y),digits=4),
             "NN=",
             signif(sd(z),digits=4))
ylabel="Predicted"
graphScatterplot(x,y,z,title,xlabel,ylabel,xmax=xmax,ymax=ymax)
points(x,z, col= "black")

#PLS: Actual vs Predicted (y3)
y<-predHold$predictedMeasurements[,"y3"]
x<-holdData[,"y3"]
z<-nnPredData[,"y3"]
title="Actual vs Predicted (y3)"
xlabel=paste("Mean: Act=",
             signif(mean(x),digits=4),
             "PLS=",
             signif(mean(y),digits=4),
             "NN=",
             signif(mean(z),digits=4),
             "\n SD: Act=",
             signif(sd(x),digits=4),
             "PLS=",
             signif(sd(y),digits=4),
             "NN=",
             signif(sd(z),digits=4))
ylabel="Predicted"
graphScatterplot(x,y,z,title,xlabel,ylabel,xmax=xmax,ymax=ymax)
points(x,z, col= "black")

#PLS: Actual vs Predicted (y3)
y<-predHold$predictedMeasurements[,"y4"]
x<-holdData[,"y4"]
z<-nnPredData[,"y4"]
title="Actual vs Predicted (y4)"
xlabel=paste("Mean: Act=",
             signif(mean(x),digits=4),
             "PLS=",
             signif(mean(y),digits=4),
             "NN=",
             signif(mean(z),digits=4),
             "\n SD: Act=",
             signif(sd(x),digits=4),
             "PLS=",
             signif(sd(y),digits=4),
             "NN=",
             signif(sd(z),digits=4))
ylabel="Predicted"
graphScatterplot(x,y,z,title,xlabel,ylabel,xmax=xmax,ymax=ymax)
points(x,z, col= "black")

#Set the panels
par(mfrow=c(2,2))

title<-"PLS vs NN Residuals"

graphCombinedResiduals("y1",nnPredResiduals,predHold$residuals,title,c(-4,4),c(0,0.8),10,"NN","PLS")

graphCombinedResiduals("y2",nnPredResiduals,predHold$residuals,title,c(-4,4),c(0,0.8),10,"NN","PLS")

graphCombinedResiduals("y3",nnPredResiduals,predHold$residuals,title,c(-4,4),c(0,0.8),10,"NN","PLS")

graphCombinedResiduals("y4",nnPredResiduals,predHold$residuals,title,c(-4,4),c(0,0.8),10,"NN","PLS")
