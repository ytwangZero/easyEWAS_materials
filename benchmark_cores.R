library(IlluminaHumanMethylation450kanno.ilmn12.hg19)
library(tidyverse)
library(easyEWAS)
library(microbenchmark)
library(doParallel)
library(foreach)
library(ggplot2)

ann = getAnnotation("IlluminaHumanMethylation450kanno.ilmn12.hg19")
ann = as.data.frame(ann)

# generate data-----------------------------------------------------------------
set.seed(123)
num_samples <- 10
num_sites <- nrow(ann)
methylation_data <- matrix(runif(num_sites * num_samples, min = 0, max = 1),
                           nrow = num_sites, ncol = num_samples)
colnames(methylation_data) <- paste0("Sample_", 1:num_samples)
methylation_data %>% 
  as.data.frame() %>% 
  mutate(probe = rownames(ann)) %>% 
  select(probe, everything()) -> methylation_data

sample_data <- data.frame(
  Sample_ID = paste0("Sample_", 1:num_samples),
  expo = rnorm(num_samples, mean = 50, sd = 10)
)

# set parameters ---------------------------------------------------------------
model = "lm"
expo = "expo"
df_beta = methylation_data[-1]
rownames(df_beta) = methylation_data$probe
covdata = sample_data[-1]

ewasfun <- function(cg,ff,cov){
  cov$cpg = as.vector(t(cg))
  out <- base::summary(lm(ff, data = cov))
  temp = as.vector(out$coefficients[2,c(1,2,4)])
  return(temp)
}

formula = as.formula("cpg ~ expo")


# benchmarking------------------------------------------------------------------
len = nrow(methylation_data)
max_cores <- 30
results <- data.frame(cores = integer(), time = numeric())

for (no_cores in seq(10, max_cores, by = 2)) { 
  cl <- makeCluster(no_cores)
  registerDoParallel(cl)
  
  chunk.size <- ceiling(len / no_cores)
  time_taken <- system.time({
    modelres <- foreach(i = 1:no_cores, .combine = 'rbind') %dopar% {
      restemp <- matrix(0, nrow = min(chunk.size, len - (i - 1) * chunk.size), ncol = 3)
      for (x in ((i - 1) * chunk.size + 1):min(i * chunk.size, len)) {
        restemp[x - (i - 1) * chunk.size, ] <- as.numeric(base::t(ewasfun(df_beta[x, ], formula, covdata)))
      }
      restemp
    }
  })
  
  stopCluster(cl)  
  
  results <- rbind(results, data.frame(cores = no_cores, time = time_taken["elapsed"]))
}

print(results)