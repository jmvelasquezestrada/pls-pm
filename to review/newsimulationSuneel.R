##############################################################
############# Data Simulation#################################
##############################################################

## Only reflective for now


rm(list=ls())

require(simsem)

loading <- matrix(0, 12, 3)
loading[1:4, 1] <- NA
loading[5:8, 2] <- NA
loading[9:12, 3] <- NA

LY <- bind(loading, 0.7)

## Latent variables

latent.cor <- matrix(NA, 3, 3)
diag(latent.cor) <- 1
RPS <- binds(latent.cor, 0.5)
RTE <- binds(diag(12))
VY <- bind(rep(NA,12),3)

# Regression 
path <- matrix(0, 3, 3)
path[3, 1:2] <- NA
path.start <- matrix(0, 3, 3)
path.start[3, 1] <- "rnorm(1,0.6,0.05)"
path.start[3, 2] <- "runif(1,0.3,0.5)"
BE <- bind(path, path.start)



CFA.Model <- model(BE=BE,LY = LY, RPS = RPS, RTE = RTE, modelType = "SEM")
dat <- generate(CFA.Model,183)

write.csv(dat,"simulated.csv")






















# require(mnormt)
# 
# # 3 latent variable from multinormal distribution
# n=100
# mu=rep(0,2)
# Sigma=matrix(c(1,0.5,0.5,1),2,2,byrow = T)
# set.seed(123)
# eta.exo=rmnorm(n,mu,Sigma)
# set.seed(1)
# e.str=rnorm(n,0,sqrt(0.5))  ## to make sure the eta.endo has variance 1
# eta.endo=0.5*eta.exo[,1]-0.5*eta.exo[,2]+e.str  # (same model as what we
# # were using)
# cor(cbind(eta.exo,eta.endo))  # cross check
# 
# # 4 reflective items for each latent
# set.seed(1)
# e=rnorm(n,0,0.3)
# # items for latent 1
# i11=1+0.7*eta.exo[,1]+e
# i12=1+0.5*eta.exo[,1]+e
# i13=-1+0.6*eta.exo[,1]+e
# i14=-1+0.7*eta.exo[,1]+e
# 
# # items for latent 2
# i21=1+0.7*eta.exo[,2]+e
# i22=1+0.5*eta.exo[,2]+e
# i23=-1+0.6*eta.exo[,2]+e
# i24=-1+0.7*eta.exo[,2]+e
# 
# # items for latent 3 (eta.endo: dependent variable)
# i31=1+0.7*eta.endo+e
# i32=1+0.5*eta.endo+e
# i33=-1+0.6*eta.endo+e
# i34=-1+0.7*eta.endo+e
# 
# data=data.frame(cbind(i11,i12,i13,i14,i21,i22,i23,i24,i31,i32,i33,i34))
