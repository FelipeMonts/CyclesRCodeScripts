##############################################################################################################
# 
# 
# Program to get soil files for cycles from a shape file and a raster fiel
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

# install.packages('soilDB', dep=TRUE) # stable version from CRAN + dependencies
# install.packages("soilDB", repos="http://R-Forge.R-project.org") # most recent copy from r-forge

# install.packages("rgdal", dep = TRUE)

# install.packages("aqp", dep=TRUE)

# install.packages("reshape2", dep=TRUE)

#install.packages("openxlsx", dep=TRUE)





###############################################################################################################
#                           load the libraries that are neded   
###############################################################################################################

library(rgdal) ; 

library(soilDB) ;

library(aqp) ;

library(reshape2) ;

library(openxlsx);




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

###############################################################################################################
#                           Query the Soil Data access database with SQL through R
###############################################################################################################

# from https://sdmdataaccess.sc.egov.usda.gov/queryhelp.aspx
# and https://sdmdataaccess.sc.egov.usda.gov/documents/ReturningSoilTextureRelatedAttributes.pdf


# --Sample query begins.
# --Note that a pair of dashes denotes the beginning of a comment. 
# SELECT
# saversion, saverest, -- attributes from table "sacatalog"
# l.areasymbol, l.areaname, l.lkey, -- attributes from table "legend"
# musym, muname, museq, mu.mukey, -- attributes from table "mapunit"
# comppct_r, compname, localphase, slope_r, c.cokey, -- attributes from table "component"
# hzdept_r, hzdepb_r, ch.chkey, -- attributes from table "chorizon"
# sandtotal_r, silttotal_r, claytotal_r, --total sand, silt and clay fractions from table "chorizon"
# sandvc_r, sandco_r, sandmed_r, sandfine_r, sandvf_r,--sand sub-fractions from table "chorizon"
# texdesc, texture, stratextsflag, chtgrp.rvindicator, -- attributes from table "chtexturegrp"
# texcl, lieutex, -- attributes from table "chtexture"
# texmod -- attributes from table "chtexturemod"
# FROM sacatalog sac
# INNER JOIN legend l ON l.areasymbol = sac.areasymbol AND l.areatypename = 'Non-MLRA Soil Survey Area'
# INNER JOIN mapunit mu ON mu.lkey = l.lkey
# AND mu.mukey IN
# ('107559','107646','107674','107682','107707','107794','107853','107854','107865','107867','107869','107870','107871')
# LEFT OUTER JOIN component c ON c.mukey = mu.mukey
# LEFT OUTER JOIN chorizon ch ON ch.cokey = c.cokey
# LEFT OUTER JOIN chtexturegrp chtgrp ON chtgrp.chkey = ch.chkey
# LEFT OUTER JOIN chtexture cht ON cht.chtgkey = chtgrp.chtgkey
# LEFT OUTER JOIN chtexturemod chtmod ON chtmod.chtkey = cht.chtkey
# --WHERE.
# --ORDER BY l.areaname, museq, comppct_r DESC, compname, hzdept_r -- standard soil report ordering
# --Sample query ends. 

# extract the map unit keys from the RAT, and format for use in an SQL IN-statement
#in.statement2 <- format_SQL_in_statement(MUKEYS$ID); 

in.statement2 <- format_SQL_in_statement(MUKEYS); 

# The above is teh same as the two instructions below combined 
# Temp_1 <- paste(MUKEYS, collapse="','") ;
# Temp_2<- paste("('", Temp_1 , "')", sep='') ;



# format query in SQL- raw data are returned


 # Pedon.query<- paste0("SELECT component.mukey, component.cokey, component.compname, component.taxorder, component.taxsuborder, component.taxgrtgroup, component.taxsubgrp, comppct_r, majcompflag, slope_r, hzdept_r, hzdepb_r,hzthk_r, hzname, awc_r, sandtotal_r, silttotal_r, claytotal_r, om_r,dbtenthbar_r, dbthirdbar_r, dbfifteenbar_r, fraggt10_r, frag3to10_r, sieveno10_r, sieveno40_r, sieveno200_r, ksat_r, hydgrp  FROM component JOIN chorizon ON component.cokey = chorizon.cokey AND mukey IN", in.statement2," ORDER BY component.mukey, comppct_r DESC, hzdept_r ASC") ;
 # 


Pedon.query<- paste0("SELECT muaggatt.musym, muaggatt.drclassdcd, muaggatt.hydgrpdcd, component.mukey, component.cokey, component.compname, component.taxorder, component.taxsuborder, component.taxgrtgroup, component.taxsubgrp, comppct_r, majcompflag, slope_r, hzdept_r, hzdepb_r,hzthk_r, hzname, awc_r, sandtotal_r, silttotal_r, claytotal_r, om_r,dbtenthbar_r, dbthirdbar_r, dbfifteenbar_r, fraggt10_r, frag3to10_r, sieveno10_r, sieveno40_r, sieveno200_r, ksat_r  FROM component JOIN chorizon ON component.cokey = chorizon.cokey
                     JOIN muaggatt ON muaggatt.mukey = component.mukey AND component.mukey IN", in.statement2," ORDER BY component.mukey, comppct_r DESC, hzdept_r ASC") ;


# now get component and horizon-level data for these map unit keys
Pedon.info<-SDA_query(Pedon.query);
head(Pedon.info) ;
str(Pedon.info)  ;


View(Pedon.info)

# filter components that are the major components of each unit map with the Flag majcompflag=='Yes'

Pedon.info.MajorC<-Pedon.info[which(Pedon.info$majcompflag == 'Yes'),]  ;
head(Pedon.info.MajorC) ; 
str(Pedon.info.MajorC)  ;



# check if there are mukeys with more than one dominant component

Pedon.info.MajorC$mukey.factor<-as.factor(Pedon.info.MajorC$mukey) ;

str(Pedon.info.MajorC$mukey.factor)


Pedon.info.MajorC$mukey_comppct_r<-paste(Pedon.info.MajorC$mukey.factor,Pedon.info.MajorC$comppct_r, sep = "_") ;

# Select major component mukeys that have also the highest component percent comppct_r

head(Pedon.info.MajorC)  ;

Dominant<- aggregate(comppct_r ~ mukey.factor, data=Pedon.info.MajorC, FUN="max" , drop=T, simplify=T) ;

head(Dominant)  ;

str(Dominant) ;

Dominant$mukey_comppct_r<-paste(Dominant$mukey.factor,Dominant$comppct_r, sep ="_");


Mukey.Pedon<-Pedon.info.MajorC[Pedon.info.MajorC$mukey_comppct_r %in% Dominant$mukey_comppct_r,]  ;

str(Mukey.Pedon) ;


# Creating Mukey ID for each dominant component


Mukey.Pedon$mukey_ID<-as.character(Mukey.Pedon$mukey) ;


str(Mukey.Pedon);


#  Transform the Pedon.info query in to the right format to be converted into a SoilProfileCollection object
#   https://ncss-tech.github.io/AQP/aqp/aqp-intro.html


#Pedon.info$id<-Pedon.info$mukey ;
# Pedon.info$top<-Pedon.info$hzdept_r ;
# Pedon.info$bottom<-Pedon.info$hzdept_r ;
#Pedon.info$name<-Pedon.info$hzname ;

depths(Mukey.Pedon)<-mukey_ID ~ hzdept_r + hzdepb_r  ;
str(Mukey.Pedon@horizons) ;


plot(Mukey.Pedon, name='hzname',color='dbthirdbar_r')  ;

plot(Mukey.Pedon[3:10,], name='hzname',color='hydgrp')  ;



###############################################################################################################
#                            Get the curve number from the hydrology condition in surgo and the 
#                             crop type from the TR55 publication
#                          "Urban Hydrology for Small Watersheds TR-55." 1986. USDA-NRCS.
#                      https://www.nrcs.usda.gov/Internet/FSE_DOCUMENTS/stelprdb1044171.pdf.
#
###############################################################################################################



### Read the table comiled in the excel file CurveNumberTR55.xlsx
### for the future, the tables for Ag and pasture and arid lands can be combined iot one and can be used for everything 


TR55_AgLands.table<-read.xlsx('C:\\Felipe\\CYCLES\\CyclesRCodeScripts\\CurveNumberTR55.xlsx', sheet='CultivatedAgriculture',startRow=2)


str(TR55_AgLands.table)

### Transform the table wide format into a long format with the melt fuction in the reshape2 package

TR55_AgLands<-melt(TR55_AgLands.table, id.vars=c('Cover.type', 'Treatment' , 'Hydrologic.condition'), measure.vars=c('A' , 'B' , 'C' , 'D'), variable.name ='HydrologicSoilGroup', value.name = 'Curve.Number')  ;


str(TR55_AgLands)


### completing the variables missing from the SSURGO query

str(Mukey.Pedon@horizons)

View(Mukey.Pedon@horizons)

Mukey.Pedon@horizons$Cover.type<-c('Row crops') ;
Mukey.Pedon@horizons$Treatment<-c('SR');
Mukey.Pedon@horizons$Hydrologic.condition<-c('Good') ;

### Link the pedon data frame  with the TR55 data frame to get the curve number

Pedon.dataframe<-Mukey.Pedon@horizons ;

str(Pedon.dataframe)

Mukey.Pedon@horizons<-merge(Pedon.dataframe,TR55_AgLands,by.x=c('Cover.type', 'Treatment', 'Hydrologic.condition', 'hydgrpdcd'), by.y=c('Cover.type', 'Treatment' , 'Hydrologic.condition','HydrologicSoilGroup' ), all.x=T) ;

Mukey.Pedon@horizons[order(Mukey.Pedon@horizons$mukey),]

str(Mukey.Pedon)



###############################################################################################################
#                           Use the slab funtion on the AQP package to obtain the average parameters for the 
#                             0 to 20 cm aggregation
###############################################################################################################


Mukey.Pedon.Slabs_Cycles_0_20<-slab(Mukey.Pedon,fm=mukey_ID ~ claytotal_r + sandtotal_r + silttotal_r + om_r + dbthirdbar_r , slab.structure = c(0,20) , slab.fun=mean,na.rm=T ) ;


Mukey.Pedon.Cycles_0_20.1<-dcast(Mukey.Pedon.Slabs_Cycles_0_20, mukey_ID + top + bottom ~ variable)  ;

Mukey.Pedon.Cycles_0_20<-merge(Mukey.Pedon.Cycles_0_20.1, unique(Mukey.Pedon@horizons[, c('mukey_ID','musym','compname', 'Cover.type' ,'Treatment', 'Hydrologic.condition' , 'hydgrpdcd' , 'drclassdcd', 'Curve.Number','taxorder', 'taxsuborder' , 'taxgrtgroup' , 'taxsubgrp')]), by=c('mukey_ID'), all.x=T) ;

str(Mukey.Pedon.Cycles_0_20)


depths(Mukey.Pedon.Cycles_0_20)<-mukey_ID ~ top + bottom  ;

str(Mukey.Pedon.Cycles_0_20@horizons) 

plot(Mukey.Pedon.Cycles_0_20,  name='hzname', color='Curve.Number') ;



###############################################################################################################
#                           Use the slab funtion on the AQP package to obtain the average parameters for the 
#                             0 to 100 cm aggregation
###############################################################################################################

Mukey.Pedon.Slabs_Cycles_0_100<-slab(Mukey.Pedon,fm=mukey_ID ~ claytotal_r + sandtotal_r + silttotal_r + om_r + dbthirdbar_r , slab.structure = c(0,100) , slab.fun=mean,na.rm=T ) ;


Mukey.Pedon.Cycles_0_100.1<-dcast(Mukey.Pedon.Slabs_Cycles_0_100, mukey_ID + top + bottom ~ variable)  ;

Mukey.Pedon.Cycles_0_100<-merge(Mukey.Pedon.Cycles_0_100.1, unique(Mukey.Pedon@horizons[, c('mukey_ID','musym','compname', 'Cover.type' ,'Treatment', 'Hydrologic.condition' , 'hydgrpdcd' , 'drclassdcd', 'Curve.Number','taxorder', 'taxsuborder' , 'taxgrtgroup' , 'taxsubgrp')]), by=c('mukey_ID')) ;

str(Mukey.Pedon.Cycles_0_100)

depths(Mukey.Pedon.Cycles_0_100)<-mukey_ID ~ top + bottom  ;

str(Mukey.Pedon.Cycles_0_100@horizons) 

plot(Mukey.Pedon.Cycles_0_100,  name='hzname', color='sandtotal_r') ;

plot(Mukey.Pedon.Cycles_0_100,  name='hzname', color='Curve.Number') ;


###############################################################################################################
#                          Get all the data together into a table for RF analysis
#                            
###############################################################################################################

str(Mukey.Pedon.Cycles_0_20@horizons) 

names(Mukey.Pedon.Cycles_0_20@horizons)[c(4:8)]<-c("claytotal_r_0-20" , "sandtotal_r_0-20" , "silttotal_r_0-20" , "om_r_0-20" , "dbthirdbar_r_0-20") ;

str(Mukey.Pedon.Cycles_0_100@horizons) 

names(Mukey.Pedon.Cycles_0_100@horizons)[c(4:8)]<-c("claytotal_r_0-100" , "sandtotal_r_0-100" , "silttotal_r_0-100" , "om_r_0-100" , "dbthirdbar_r_0-100") ; 

Soil.Data.Agg<-merge(Mukey.Pedon.Cycles_0_20@horizons[],Mukey.Pedon.Cycles_0_100@horizons,by=c('mukey_ID', 'musym', 'Cover.type', 'Treatment','Hydrologic.condition', 'hydgrpdcd' , 'Curve.Number', 'taxorder' ,'taxsuborder' , 'taxgrtgroup','taxsubgrp', 'compname' , 'drclassdcd')) ;
  
View(Soil.Data.Agg)

#### create a directory to put the aggregated data together

dir.create('CyclesSoilsFromSSURGO', showWarnings = T) ;

write.xlsx(Soil.Data.Agg, file='./CyclesSoilsFromSSURGO/agregated.data.xlsx', asTable=F, sheet.Name='agregated_data');



###############################################################################################################
#                           Use the slab funtion on the AQP package to obtain the parameters at the layers
#                             needed for Cycles
###############################################################################################################


Mukey.Pedon.Cycles.Slabs<-slab(Mukey.Pedon,fm=mukey_ID ~ claytotal_r + sandtotal_r + silttotal_r + om_r + dbthirdbar_r , slab.structure = c(0,5,10,20,40,60,80,100) , slab.fun=mean,na.rm=T ) ;

Mukey.Pedon.Cycles.1<-dcast(Mukey.Pedon.Cycles.Slabs, mukey_ID + top + bottom ~ variable) ;

str(Mukey.Pedon.Cycles.1)

Mukey.Pedon.Cycles<-merge(Mukey.Pedon.Cycles.1, unique(Mukey.Pedon@horizons[, c('mukey_ID','musym', 'compname' ,'Cover.type' ,'Treatment', 'Hydrologic.condition' , 'hydgrpdcd' , 'drclassdcd' , 'Curve.Number','taxorder', 'taxsuborder' , 'taxgrtgroup' , 'taxsubgrp')]), by=c('mukey_ID')) ;

str(Mukey.Pedon.Cycles)

depths(Mukey.Pedon.Cycles)<-mukey_ID ~ top + bottom  ;


str(Mukey.Pedon.Cycles@horizons$) 


plot(Mukey.Pedon, name='hzname',color='sandtotal_r')  ;

plot(Mukey.Pedon.Cycles,  name='hzname', color='Curve.Number') ;

View(Mukey.Pedon.Cycles@horizons)
