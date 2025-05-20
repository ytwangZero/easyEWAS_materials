if (getRversion() >= "4.4.0") {
  
  install_if_missing <- function(pkg, use_bioc = FALSE) {
    if (!pkg %in% rownames(installed.packages())) {
      if (use_bioc) {
        BiocManager::install(pkg, ask = FALSE, update = FALSE)
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
  if (!requireNamespace("BiocManager", quietly = TRUE)) {
    message("Installing BiocManager...")
    install.packages("BiocManager")
  }
  
  ## Step 2: Ensure correct Bioconductor version
  if (package_version(as.character(BiocManager::version())) < package_version("3.20")) {
    message("Bioconductor 3.20 is required. Updating Bioconductor...")
    BiocManager::install(version = "3.20")
  }
  
  ## Step 3: Install all dependencies BEFORE installing easyEWAS
  message("\n================ Installing dependencies for easyEWAS ====================\n")
  
  cran_pkgs <- c("dichromat","remotes")
  for (pkg in bioc_pkgs) {
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
  tryCatch({
    remotes::install_github("ytwangzero/easyEWAS", force = TRUE)
    message("\n🎉✨ easyEWAS installation completed successfully! ✨🎉")
  }, error = function(e) {
    message("\n❌ easyEWAS installation failed: ", conditionMessage(e))
  })
  
} else {
  stop("Your R version is ", getRversion(), 
       ". Please upgrade to R version 4.4.0 or higher to install easyEWAS.")
}
