##############################################################################################################
# 
# 
# Program to plot soil data from cycles output
# 
# Felipe Montes 2019  03 29
# 
# 
# 
# 
############################################################################################################### 



###############################################################################################################
#                          Loading Packages and setting up working directory                        
###############################################################################################################



#  Tell the program where the package libraries are  #####################


.libPaths("C:/Felipe/SotwareANDCoding/R_Library/library")  ;

#  Set Working directory

setwd("C:/Felipe/CYCLES") ;


#Loand And install packages 
#install.packages('readxl', dependencies = T)

library(readxl) ;


# Create a directory for sumarizing outputs

dir.create("SoilGraphOutput") ;

#  initialize the dataframe where data will be collected

  
  ###############################################################################################################
  #                         Read data sets into R            
  ###############################################################################################################
  
 SoilLayersCN.Labels.1<-trimws(read.table("./ContinuousCorn/soilLayersCN.dat", header = F, nrows=1, sep='\t',as.is=T)) ;
 SoilLayersCN.Labels.2<-trimws(read.table("./ContinuousCorn/soilLayersCN.dat", header = F, skip=1,nrows=1,sep='\t', as.is=T)) ; 
 SoilLayersCN.Labels.3<-trimws(read.table("./ContinuousCorn/soilLayersCN.dat", header = F, skip=2,nrows=1,sep='\t', as.is=T)) ; 
 
#  
#  Data.scan<-scan("./ContinuousCorn/soilLayersCN.dat", what="raw")
#  
#  str(Data.scan)
# 
#  Data.scan[900:1600]
#  
# matrix(Data.scan,nrow=127)
# 
# 
# 
# 
#  
#  SoilLayersCN.Labels.colClasses<-c("character", "Date",rep("numeric", 125)) ;
#  
# 
#  
 
 SoilLayersCN.Headers<-t(paste(t(SoilLayersCN.Labels.1),t(SoilLayersCN.Labels.2),t(SoilLayersCN.Labels.3),sep=".") );
 
 SoilLayersCN.Headers[128]<-'NA' ;
 
 SoilLayersCN.Data<-read.table("./ContinuousCorn/soilLayersCN.dat", header = F, skip=3, sep='\t', col.names =SoilLayersCN.Headers );
 
 head(SoilLayersCN.Data)
 
 
 SoilLayersCN.Data$DOY<-as.POSIXlt(SoilLayersCN.Data$DATE...YYYY.MM.DD)[,"yday"]  ;
 
 SoilLayersCN.Data$Year<-as.factor(as.POSIXlt(SoilLayersCN.Data$DATE...YYYY.MM.DD)[,"year"])  ;
 
 str(SoilLayersCN.Data$Year)
 
 levels(SoilLayersCN.Data$Year)
 
 Test.data<-SoilLayersCN.Data[SoilLayersCN.Data$Year==80,c(1:12,129,130)]  ;
 
 head(Test.data)
 str(Test.data)
 
 # Soil Layers
 # 1-0.00
 # 2-0.05
 # 3-0.10
 # 4-0.20
 # 5-0.40
 # 6-0.60
 # 7-0.80
 # 8-1.00
 # 9-1.20
 
 SoilLayers.depth_m<-data.frame(SoilLayersCN.Labels.2[3:11],c(0.01, 0.05, 0.10, 0.20, 0.40, 0.60, 0.80, 1.00, 1.20));
 names(SoilLayers.depth_m)<-c("LAYER", "Depth_m") ;
 
 SoilLayers.depth_m<-data.frame(SoilLayersCN.Labels.2[3:11],c(0.01, 0.05, 0.10, 0.20, 0.40, 0.60, 0.80, 1.00, 1.20),c(-0.01, -0.05, -0.10, -0.20, -0.40, -0.60, -0.80, -1.00, -1.20));
 
 names(SoilLayers.depth_m)<-c("LAYER", "Depth_m", "Depth_m_neg") ;

 
# plot a contour plot of the variable as func tion of time and soil depth
# arrange the data for plotting in a matrix with x=time, y=layer, z=variable value

 NO3Matrix<-as.matrix(Test.data[,3:11]) ;
 
 NO3Matrix_neg<-as.matrix(Test.data[,11:3]) ;
 
 
 
 head(NO3Matrix)
 head(NO3Matrix_neg)
 
 
 str(NO3Matrix)
 
 filled.contour(x=Test.data[,"DOY"],y=SoilLayers.depth_m[,2],z=NO3Matrix,color.palette=rainbow,nlevels=10);
 
 filled.contour(x=Test.data[,"DOY"],y=SoilLayers.depth_m[9:1,3],z=NO3Matrix_neg,color.palette=rainbow,nlevels=10);

 #Plot the other variables and other years
 
 #NH4
 
 head(SoilLayersCN.Data)[,99:107]
 
 str(SoilLayersCN.Data)
 
 NH4.data<-SoilLayersCN.Data[SoilLayersCN.Data$Year==80,c(21:13,129,130)]  ;
 
 NH4.Matrix_neg<-as.matrix(NH4.data[,1:9]) ;

 head(NH4.Matrix_neg) 
 
 filled.contour(x=Test.data[,"DOY"],y=SoilLayers.depth_m[9:1,3],z=NH4.Matrix_neg,color.palette=rainbow,nlevels=10);
 
 
 #Water Content

 Water.data<-SoilLayersCN.Data[SoilLayersCN.Data$Year==80,c(107:99,129,130)]  ;
 head(Water.data)
 
 Water.data.Matrix_neg<-as.matrix(Water.data[,1:9]) ;
 
 
 
 
 filled.contour(x=Test.data[,"DOY"], y=SoilLayers.depth_m[9:1,3], z=Water.data.Matrix_neg , color.palette=rainbow,nlevels=10);

 
 #SOil Orga Content 
 
 head(SoilLayersCN.Data)[,89:97]
 
 
 SORGC.data<-SoilLayersCN.Data[SoilLayersCN.Data$Year==80,c(97:89,129,130)]  ;
 head(SORGC.data)
 
 SORGC.data.Matrix_neg<-as.matrix(SORGC.data[,1:9]) ;
 
 
 
 
 filled.contour(x=Test.data[,"DOY"], y=SoilLayers.depth_m[9:1,3], z=SORGC.data.Matrix_neg , color.palette=rainbow,nlevels=10);
 
 