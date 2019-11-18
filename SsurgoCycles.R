##############################################################################################################
# 
# 
# Program to get soil files for cycles
# 
#     
# 
#    
# 
# 
#  Felipe Montes 2019 11/18
# 
# 
# 
# 
############################################################################################################### 



###############################################################################################################
#                             Tell the program where the package libraries are stored                        
###############################################################################################################


#  Tell the program where the package libraries are  #####################

.libPaths("C:/Felipe/SotwareANDCoding/R_Library/library")  ;


###############################################################################################################
#                             Setting up working directory  Loading Packages and Setting up working directory                        
###############################################################################################################


#      set the working directory



setwd('C:/Felipe/CYCLES/CyclesRCodeScripts/CyclesRCodeScripts/SSurgoSoilsCycles') ;     


###############################################################################################################
#                            Install the packages that are needed                       
###############################################################################################################


# Install the packages that are needed #

# Install the packages that are needed #


# install.packages("raster", dep = TRUE)
# install.packages('Hmisc', dep=TRUE)
# install.packages('soilDB', dep=TRUE) # stable version from CRAN + dependencies
# install.packages("soilDB", repos="http://R-Forge.R-project.org") # most recent copy from r-forge
# install.packages("SSOAP", repos = "http://www.omegahat.org/R", type="source") # SSOAP and XMLSchema
# install.packages("rgdal", dep = TRUE)

# install.packages("rgeos", dep = TRUE)
# install.packages("RColorBrewer")
# install.packages("latticeExtra")
# install.packages("aqp", dep=TRUE)





###############################################################################################################
#                           load the libraries that are neded   
###############################################################################################################

library(rgdal) ; 



###############################################################################################################
#                           import the shape files from QGIS with the MUKEY mode from each triangle 
###############################################################################################################



########### Read infromation about the shape files ###########


Project.mesh.info<-ogrInfo('C:/Felipe/PIHM-CYCLES/PIHM/PIHM SIMULATIONS/YAHARA/Oct0920191330/DomainDecomposition/MergeFeatures_q30_a1000000_o.shp')  ; 


#### read the shape file that has been created in QGIS using the zonal statistics


Project.GSSURGO<-readOGR('C:/Felipe/PIHM-CYCLES/PIHM/PIHM SIMULATIONS/YAHARA/Oct0920191330/DomainDecomposition/MergeFeatures_q30_a1000000_o.shp')  ;  

head(Project.GSSURGO@data)


str(Project.GSSURGO, max.level = 2) ;


plot(Project.GSSURGO) ;


str(Project.GSSURGO@data)  ; 

#### Extract the Mukeys corresponding to the mode in each mesh triangle


Project.GSSURGO@data$MUKEYS.mode<-as.factor(Project.GSSURGO@data$GSURGO_Mod) ;

MUKEYS<-levels(Project.GSSURGO@data$MUKEYS.mode)  ;

str(MUKEYS)  ;


################################ Query the Soil Data access database with SQL through R #################



