library(tidyverse)
##
##
##====================================================================
##===============  FUNCTIONS  ========================================
##====================================================================
##
##====== Transforming natural parameters to working===================
##
pn2pw <- function(m,pi,gamma,delta=NULL,stationary=TRUE)
{
  tpi <- logit(pi)
  if(m==1) return(tpi)
  foo     <- log(gamma/diag(gamma))
  tgamma  <- as.vector(foo[!diag(m)])
  if(stationary) {tdelta  <- NULL}
  else {tdelta <- log(delta[-1]/delta[1])}
  parvect <- c(tpi,tgamma,tdelta)
  return(parvect)
}
##
##======= Transforming working parameters to natural==================
##
pw2pn <- function(m,parvect,stationary=TRUE)
{
  pi        <- inv.logit(parvect[1:m])
  gamma         <- diag(m)
  if (m==1) return(list(pi=pi,gamma=gamma,delta=1))
  gamma[!gamma] <- exp(parvect[(m+1):(m*m)])
  gamma         <- gamma/apply(gamma,1,sum)
  if(stationary){delta<-solve(t(diag(m)-gamma+1),rep(1,m))}
  else {foo<-c(1,exp(parvect[(m*m+1):(m*m+m-1)]))
  delta<-foo/sum(foo)}
  return(list(pi=pi,gamma=gamma,delta=delta))
}
##
##= Computing minus the log-likelihood from the working parameters ===
##
mllk <- function(parvect, x, m, stationary = TRUE, ...)
{
  if (m == 1)
    return(-sum(dnbinom(x, prob=1-inv.logit(parvect), log = TRUE)))
  n        <- length(x)
  pn       <- pw2pn(m, parvect, stationary = stationary)
  foo      <- pn$delta * dnbinom(x[1],size=Prev[1],prob=1-pn$pi)
  sumfoo   <- sum(foo)
  lscale   <- log(sumfoo)
  foo      <- foo / sumfoo
  for (i in 2:n)
  {
    if (!is.na(x[i])) {
      P <- dnbinom(x[i],size=Prev[i],prob=1-pn$pi)
    }
    else {
      P <- rep(1, m)
    }
    foo    <- foo %*% pn$gamma * P
    sumfoo <- sum(foo)
    lscale <- lscale + log(sumfoo)
    foo    <- foo / sumfoo
  }
  mllk     <- -lscale
  return(mllk)
}
##
##Computing the MLEs, given starting values for the natural parameters
##
HMM.mle <-function(x,m,pi0,gamma0,delta0=NULL,stationary=TRUE,...)
{
  parvect0  <- pn2pw(m,pi0,gamma0,delta0,stationary=stationary)
  mod       <- nlm(mllk,parvect0,x=x,m=m,
                   stationary=stationary,iterlim=500)
  pn        <- pw2pn(m=m,mod$estimate,stationary=stationary)
  mllk      <- mod$minimum
  np        <- length(parvect0)
  AIC       <- 2*(mllk+np)
  n         <- sum(!is.na(x))
  BIC       <- 2*mllk+np*log(n)
  list(m=m,pi=pn$pi,gamma=pn$gamma,delta=pn$delta,code=mod$code,mllk=mllk,AIC=AIC,BIC=BIC)
}
##
##==============  Generating a sample ================================
##
HMM.generate_sample  <- function(ns,mod){
  mvect <- 1:mod$m
  state <- numeric(ns)
  state[1]<- sample(mvect,1,prob=mod$delta)
  for (i in 2:ns){
    state[i] <- sample(mvect,1,prob=mod$gamma[state[i-1],])
  }
  #sa <- rnbinom(ns,size=Prev,prob=mod$pi[state])
  sa <- rpois(ns,lambda=Prev*(mod$pi[state]/(1+mod$pi[state])))
  return(sa)
}
##
##====== Global decoding by the Viterbi algorithm ====================
##
HMM.viterbi<-function(x,mod)
{
  n              <- length(x)
  xi             <- matrix(0,n,mod$m)
  foo            <- mod$delta*dnbinom(x[1],size=Prev[1],mod$pi)
  xi[1,]         <- foo/sum(foo)
  for (i in 2:n)
  {
    foo<-apply(xi[i-1,]*mod$gamma,2,max)*dnbinom(x[i],size=Prev[i],prob=1-mod$pi)
    xi[i,] <- foo/sum(foo)
  }
  iv<-numeric(n)
  iv[n]     <-which.max(xi[n,])
  for (i in (n-1):1)
    iv[i] <- which.max(mod$gamma[,iv[i+1]]*xi[i,])
  return(iv)
}
##
##==== Computing log(forward probabilities)===========================
##
HMM.lforward<-function(x,mod)
{
  n             <- length(x)
  lalpha        <- matrix(NA,mod$m,n)
  #foo           <- mod$delta*dnbinom(x[1],size=Prev[1],mod$pi)
  foo           <- mod$delta*dpois(x[1],lambda=Prev[1]*odds(mod$pi))
  sumfoo        <- sum(foo)
  lscale        <- log(sumfoo)
  foo           <- foo/sumfoo
  lalpha[,1]    <- lscale+log(foo)
  for (i in 2:n)
  {
    #foo          <- foo%*%mod$gamma*dnbinom(x[i],size=Prev[i],mod$pi)
    foo          <- foo%*%mod$gamma*dpois(x[i],
                                          lambda=Prev[i]*odds(mod$pi))
    sumfoo       <- sum(foo)
    lscale       <- lscale+log(sumfoo)
    foo          <- foo/sumfoo
    lalpha[,i]   <- log(foo)+lscale
  }
  return(lalpha)
}
##
###==== Computing log(backward probabilities)=========================
##
HMM.lbackward<-function(x,mod)
{
  n          <- length(x)
  m          <- mod$m
  lbeta      <- matrix(NA,m,n)
  lbeta[,n]  <- rep(0,m)
  foo        <- rep(1/m,m)
  lscale     <- log(m)
  for (i in (n-1):1)
  {
    #foo <- mod$gamma%*%(dnbinom(x[i+1],size=Prev[i+1],mod$pi)*foo)
    foo <- mod$gamma%*%(dpois(x[i+1],
                                lambda=(Prev[i+1]*odds(mod$pi)))*foo)
    lbeta[,i]  <- log(foo)+lscale
    sumfoo     <- sum(foo)
    foo        <- foo/sumfoo
    lscale     <- lscale+log(sumfoo)
  }
  return(lbeta)
}
##
##===========Conditional probabilities ===============================
##
## Conditional probability that observation at time t equals
##  xc, given all observations other than that at time t.
##  Note: xc is a vector and the result (dxc) is a matrix.
##
HMM.conditional <- function(xc,x,mod)
{
  n         <- length(x)
  m         <- mod$m
  nxc       <- length(xc)
  dxc       <- matrix(NA,nrow=nxc,ncol=n)
  Px        <- matrix(NA,nrow=m,ncol=nxc)
  #for (j in 1:nxc) Px[,j] <-dnbinom(xc[j],size=Prev[j],mod$pi)
  for (j in 1:nxc) Px[,j] <-dpois(xc[j],lambda=Prev[j]*mod$pi)
  la        <- HMM.lforward(x,mod)
  lb        <- HMM.lbackward(x,mod)
  la        <- cbind(log(mod$delta),la)
  lafact    <- apply(la,2,max)
  lbfact    <- apply(lb,2,max)
  for (i in 1:n)
  {
    foo      <-
      (exp(la[,i]-lafact[i])%*%mod$gamma)*exp(lb[,i]-lbfact[i])
    foo      <- foo/sum(foo)
    dxc[,i]  <- foo%*%Px
  }
  return(dxc)
}
##
##===== Pseudo-residuals (low,mid,high) ==============================
##
pseudo_residuals <- function(x,mod)
{
  n        <- length(x)
  cdists   <- HMM.conditional(xc=0:max(x),x,mod)
  cumdists <- rbind(rep(0,n),apply(cdists,2,cumsum))
  ulo <- uhi <- rep(NA,n)
  for (i in 1:n)
  {
    ulo[i]  <- cumdists[x[i]+1,i]
    uhi[i]  <- cumdists[x[i]+2,i]
  }
  umi       <- 0.5*(ulo+uhi)
  npsr     <- qnorm(rbind(ulo,umi,uhi))
  return(npsr)
}
##
##============== logit and inv.logit functions =======================
##
logit <- function(x) {
  log(x/(1-x))
}
##
inv.logit <- function(x){exp(x)/(1+exp(x))}
##
##============== Create sum previous x days (or weeks) ===============
##
stepback <- function(back,x){
  psum <- vector(length = length(x))
  psum[1] <- NA
  for (i in 2:length(x)) {
    psum[i] <- sum(x[(i-min(i-1,back)):(i-1)])
  }
  return(psum)
}
dnegbinom <- function(x,size,prob){
  lpr <-lchoose(x+size-1,size-1)+size*log(1-prob)+x*log(prob)
  return(exp(lpr))
}
odds <- function(x){return(x/(1-x))}
