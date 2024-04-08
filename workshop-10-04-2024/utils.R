

# Function to plot first and 2nd derivatives
##' @author  Jemay SALOMON 
plotDeriv = function(X, lambda, derivatives, tsf = NULL)
{
  
  temp = list()
  
  if (!is.matrix(X) || !is.numeric(X)) {
    stop("X must be a numeric matrix")
  }
  
  if (!is.vector(lambda) || !is.numeric(lambda)) {
    stop("lambda must be a numeric matrix")
  }
  
  if (!is.numeric(tsf)) {
    stop(" tsf must be a numeric value")
  }
  
  if(is.null(tsf)){
    tsf <- (max(lambda) - min(lambda)) / (length(lambda) - 1)
  }
  
  temp[["X"]] = X
  
  if(derivatives == "1st derivatives"){
    
    X <- as.matrix(apply(X, 2, function(x) {sgolayfilt(x, p = 2, n = 37, m = 1, ts = tsf)}))
    
  } else if ( derivatives == "2nd derivatives"){
    
    X <- as.matrix(apply(X, 2, function(x) { sgolayfilt(x, p = 3, n = 61, m = 2, ts = tsf)}))
    
  }else {
    
    stop("This functions only support 1st & 2nd derivatives")
    
  }
  
  rownames(X) <- rownames(temp[["X"]])
  
  return(matplot(lambda, X, type="l", lty=1, pch=0,
                 xlab = "Lambda (nm)", ylab="Absorbance", xlim=c(390, 2500)))
  
}


##' Function to filter MAF (Minor Allele Frequency)
##' @author  Jemay SALOMON
MAF =  function(X, lower, upper) {
  
  if (!is.matrix(X) || !is.numeric(X)) {
    stop("X must be a numeric matrix")
  }

  if (!is.numeric(lower)) {
    stop(" lower must be a numeric value")
  }
  
  if (!is.numeric(upper)) {
    stop(" upper must be a numeric value")
  }
  
  if (nrow(X) <= 1 || ncol(X) <= 1) {
    stop("Input matrix X must have at least 2 rows and 2 columns")
  }
  
  ## add more stop.....
  
  p <- rowMeans(X) 
  
  rm <- which(p <= lower | p >= upper) 
  
  X_filtered <- X[-rm, ]
  
  return(X_filtered)
}


# Function to compute genetic relatedness or hyperspectral similarity
##' Compute Kinship <<method vanraden>>
##' @author  Jemay SALOMON
computeSimilarity = function(X, geneticRel = TRUE){
  
  if (!is.matrix(X) || !is.numeric(X)) {
    stop("X must be a numeric matrix")
  }
  
  if(is.null(geneticRel)){
    stop("This parameter can't be null")
  }
  
  if (nrow(X) <= 1 || ncol(X) <= 1) {
    stop("Input matrix X must have at least 2 rows and 2 columns")
  }
  
  ## add more stop.....
  
  if (geneticRel) {
    
    p <- rowMeans(X)
    
    q <- 1 - p
    
    X_scaled <- scale(2 * t(X), center = 2 * p, scale = sqrt(4 * p * q))
    
  } else {
    
    X_scaled <- scale(t(X), center = TRUE, scale = TRUE)
    
  }
  
  K <- tcrossprod(X_scaled) / ncol(X_scaled)
  
  return(K)
  
}


# Functions to calculate sigma error using h2 when simulating data
##############################################################
##' @author  Jemay SALOMON
sigmaE <- function(sigma, h2){
  if(!is.numeric(sigma)){
    stop("sigma must be numeric")
  }
  
  if(!is.numeric(h2)){
    stop("h2 must be numeric")
  }
  
  return(((1 - h2) /h2) * sigma)
}

# Functions to compute incidence matrix
##############################################################
##' @author  Jemay SALOMON

mkZ <- function(df, colD) {
  stopifnot(colD %in% colnames(df),
            is.data.frame(df))
  
  genos <- unique(df[[colD]])
  nbGenos <- length(genos)
  
  Z_I <- matrix(0, nrow = nrow(df), ncol = nbGenos)
  colnames(Z_I) <- genos
  
  for (i in 1:nrow(df)) {
    idx <- which(genos == df[i, colD])
    Z_I[i, idx] <- 1
  }
  
  stopifnot(is.matrix(Z_I))
  
  return(Z_I)
}


