library(IlluminaHumanMethylation450kanno.ilmn12.hg19)
library(tidyverse)
library(easyEWAS)

ann = getAnnotation("IlluminaHumanMethylation450kanno.ilmn12.hg19")
ann = as.data.frame(ann)

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

# Initialize the EWAS module----
res <- initEWAS(outpath = "default")

# Load the data files ----
res <- loadEWAS(input = res, ExpoData =  sample_data, MethyData = methylation_data)  
head(res$Data$Expo)
head(res$Data$Methy)

# Peform the EWAS analysis -----------------------------------------------------
res <- startEWAS(input = res,
                 chipType = "450K", 
                 model = "lm",        
                 expo ="expo",                 
                 adjustP = FALSE,   
                 core = 10           
)                                     
# 181.33 sec elapsed
head(res$result)

