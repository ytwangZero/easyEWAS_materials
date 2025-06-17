if (getRversion() >= "4.4.0") {
  
  
  message("R version check passed: ", getRversion(), ".\n")
  suppressMessages(library(utils))
  
  install_if_missing <- function(pkg, use_bioc = FALSE) {
    if (!pkg %in% rownames(installed.packages())) {
      if (use_bioc) {
        BiocManager::install(pkg, ask = FALSE, force = TRUE, update = FALSE)
      } else {
        install.packages(pkg)
      }
    }
  }
  
  safe_install <- function(expr) {
    tryCatch(expr,
             error = function(e) message("Error installing package: ", conditionMessage(e)))
  }
  
  ## Step 1: Install BiocManager if needed
  message("Checking for BiocManager...")
  if (!requireNamespace("BiocManager", quietly = TRUE)) {
    message("BiocManager not found. Installing BiocManager...")
    install.packages("BiocManager")
  } else {
    message("BiocManager is already installed!\n")
  }
  
  ## Step 2: Ensure correct Bioconductor version
  options(BIOCONDUCTOR_ONLINE_VERSION_DIAGNOSIS=TRUE)
  current_bioc_ver <- as.character(BiocManager::version())
  message("Check for current Bioconductor version: ", current_bioc_ver)
  if (package_version(current_bioc_ver) < package_version("3.20")) {
    message("Bioconductor 3.20 is required. Updating Bioconductor...")
    BiocManager::install(version = "3.20", force = TRUE)
  } else {
    message("Bioconductor version is sufficient!")
  }
  
  ## Step 3: Install all dependencies BEFORE installing easyEWAS
  message("\n================ Installing dependencies for easyEWAS ====================\n")

   options(timeout = 600000000)
  
  cran_pkgs <- c("dichromat","remotes")
  for (pkg in cran_pkgs) {
    safe_install(install_if_missing(pkg, use_bioc = FALSE))
  }
  
  
  bioc_pkgs <- c("sva", 
                 "IlluminaHumanMethylation450kmanifest", "IlluminaHumanMethylation450kanno.ilmn12.hg19",
                 "IlluminaHumanMethylationEPICmanifest", "IlluminaHumanMethylationEPICanno.ilm10b4.hg19",
                 "IlluminaHumanMethylationEPICv2manifest","IlluminaHumanMethylationEPICv2anno.20a1.hg38",
                 "DMRcate", "DMRcatedata","org.Hs.eg.db", "clusterProfiler")
  for (pkg in bioc_pkgs) {
    safe_install(install_if_missing(pkg, use_bioc = TRUE))
  }
  
  
  message("\n================ All dependencies installed successfully ==================\n")
  
  ## Step 4: Install easyEWAS
  message("Installing easyEWAS from GitHub...")
  options(timeout = 600000000)
  tryCatch({
    remotes::install_github("ytwangZero/easyEWAS", force = TRUE)
  }, error = function(e) {
    message("\n easyEWAS installation failed: ", conditionMessage(e))
  })
  
  if ("easyEWAS" %in% rownames(installed.packages())) {
    message("\neasyEWAS installation completed successfully!")
  }
  
} else {
  stop("Your R version is ", getRversion(), 
       ". Please upgrade to R version 4.4.0 or higher to install easyEWAS.")
}
