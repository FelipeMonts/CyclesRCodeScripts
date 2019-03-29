#############################################################################################################################
#
#  Program to extract Weather Data from the SURFRAD Network weather station in Penn State, Pennsylvania
#  https://www.esrl.noaa.gov/gmd/grad/surfrad/pennstat.html
#  ftp://aftp.cmdl.noaa.gov/data/radiation/surfrad/Penn_State_PA/README
#
#  Felipe Montes,  2017/03/07
#
##############################################################################################################################


############################### Record Time To start##########################################################



TimeStart<-Sys.time()  ;



###############################################################################################################
#                          Loading Packages and setting up working directory                        
###############################################################################################################



#  Tell the program where the package libraries are  #####################


.libPaths("C:/Felipe/R_Library/library")

#  Set Working directory


setwd("C:/Felipe/OrganicTransitions_N2OROSE/CyclesSimulation/RoseRCodeScripts/NOAA_SURFRAD_R") ; 


###############################################################################################################
#                         Call packages neded to process the data 
#                             
###############################################################################################################


library("RCurl") ;

library("XML")   ;



###############################################################################################################
#                         Creating the list of files for the loop to read each day of the year from the 
#                             SURFRAD fttp archive
###############################################################################################################



##### read the list of years from the ftp #####

PennStSurfrad.url<-"ftp://aftp.cmdl.noaa.gov/data/radiation/surfrad/Penn_State_PA/"   ;

List_HMTML_years<-getURLContent(PennStSurfrad.url, ftp.use.epsv = FALSE, dirlistonly = TRUE)  ;

List_years<-strsplit(List_HMTML_years,"\r*\n")[[1]]   ;

List_years[List_years != "README"][1]


##### read the list of daily files from the ftp #####

List_HTML_files<-getURLContent(paste0(PennStSurfrad.url,List_years[1],"/"), ftp.use.epsv = FALSE, dirlistonly = TRUE)  ;


List_files<-strsplit(List_HTML_files,"\r*\n")[[1]] ;



###############################################################################################################
#                         Loading data from a daily data file .dat from the Penn State
#                             SURFRAD fttp archive
###############################################################################################################




### Read the station name, latitude, Long, elevation above sea levelpsuSRFRAD.data

psuSURFRAD.station.name<-readLines(paste0(PennStSurfrad.url,List_years[1],"/",List_files[1]),n=1)  ;

psuSURFRAD.station.data<-read.table(paste0(PennStSurfrad.url,List_years[1],"/",List_files[1]), skip= 1 ,nrows=1, header=F, as.is= T)  ;

names(psuSURFRAD.station.data)<-c("LATITUDE", "LONGITUDE" , "ALTITUDE" , "meters","version" ,"version_No") ;




### write the Station name and data to the file where the data formated for cycles will be stored


write(psuSURFRAD.station.name, file="SurfradData.txt") ;

write(paste(names(psuSURFRAD.station.data)[1],psuSURFRAD.station.data[1]),file="SurfradData.txt", append=T) ;

write(paste(names(psuSURFRAD.station.data)[3],psuSURFRAD.station.data[3]),file="SurfradData.txt", append=T) ;

write(c("SCREENING_HEIGHT  10"),file="SurfradData.txt", append=T);



### Define and write the column headings for the data that is to be stored in the table according to the format needed for Cycles

YEAR = 987654321 ; 

DOY = 987654321  ;

TX = 987654321  ;

TN = 987654321  ;

dw_solar= 987654321  ;

uw_solar= 987654321  ;

direct_n= 987654321  ;
     
diffuse=	987654321  ;    

RHX = 987654321  ;

RHN = 987654321  ;

WIND = 987654321  ;




#write.table(data.frame(YEAR, DOY , TX , TN , SOLAR , RHX , RHN , WIND)[F,] , file="SurfradData.txt" , append=T , row.names = F, sep="\t", quote = F ) ;

write.table(data.frame(YEAR, DOY , TX , TN , dw_solar, dw_solar_pos=dw_solar , uw_solar, uw_solar_pos=uw_solar , direct_n , direct_n_pos=direct_n , diffuse , diffuse_pos=diffuse, RHX , RHX_TN=RHX , RHN , RHN_TX=RHN , WIND)[F,] , file="SurfradData.txt" , append=T , row.names = F, sep="\t", quote = F ) ;


##### Formatting the data according to the description on the README data file and adding column names
          #####  ftp://aftp.cmdl.noaa.gov/data/radiation/surfrad/Penn_State_PA/README
          
          SurfRad.names<-c("year" #			integer	year, i.e., 1995
          , "jday" #			integer	Julian day (1 through 365 [or 366])
          , "month" #			integer	number of the month (1-12)
          , "day" #			integer	day of the month(1-31)
          , "hour" #			integer	hour of the day (0-23)
          , "min" #			integer	minute of the hour (0-59)
          , "dt" #			real	decimal time (hour.decimalminutes, e.g., 23.5 = 2330)
          , "zen" #			real	solar zenith angle (degrees)
          , "dw_solar" #		real	downwelling global solar (Watts m^-2)
          , "uw_solar" #		real	upwelling global solar (Watts m^-2)
          , "direct_n" #		real	direct-normal solar (Watts m^-2)
          , "diffuse" #		real	downwelling diffuse solar (Watts m^-2)
          , "dw_ir" #			real	downwelling thermal infrared (Watts m^-2)
          , "dw_casetemp" #		real	downwelling IR case temp. (K)
          , "dw_dometemp" #		real	downwelling IR dome temp. (K)
          , "uw_ir" #			real	upwelling thermal infrared (Watts m^-2)
          , "uw_casetemp" #		real	upwelling IR case temp. (K)
          , "uw_dometemp" #		real	upwelling IR dome temp. (K)
          , "uvb" #			real	global UVB (milliWatts m^-2)
          , "par" #			real	photosynthetically active radiation (Watts m^-2)
          , "netsolar" #		real	net solar (dw_solar - uw_solar) (Watts m^-2)
          , "netir" #			real	net infrared (dw_ir - uw_ir) (Watts m^-2)
          , "totalnet" #		real	net radiation (netsolar+netir) (Watts m^-2)
          , "temp" #			real	10-meter air temperature (?C)
          , "rh" #			real	relative humidity (%)
          , "windspd" #		real	wind speed (ms^-1)
          , "winddir" #		real	wind direction (degrees, clockwise from north)
          , "pressure" )  ; #		real	station pressure (mb)
          
          
         
          


###############################################################################################################
#                         for-loop to get all the daily data files .dat from the Penn State
#                             SURFRAD fttp archive
###############################################################################################################


for (i in List_years[List_years != "README"])  {
     
     
     List_HTML_files<-getURLContent(paste0(PennStSurfrad.url,i,"/"), ftp.use.epsv = FALSE, dirlistonly = TRUE)  ;


     List_files<-strsplit(List_HTML_files,"\r*\n")[[1]] ;
     
     

     for (j in List_files)  {
          

          psuSRFRAD.data<-read.table(paste0(PennStSurfrad.url,i,"/",j), skip=2, header=F, as.is= T)   ;
          # psuSRFRAD.data<-read.table(paste0(PennStSurfrad.url,"2000","/","psu00180.dat"), skip=2, header=F, as.is= T)  

       
          
          ### Adding names and quality control flags -QC- names to he appropriate columns:
          
          
          names(psuSRFRAD.data)[1:9]<-SurfRad.names[1:9]   ;
          names(psuSRFRAD.data)[seq(10,48,2)]<-c("QC") ;
          names(psuSRFRAD.data)[seq(11,47,2)]<-SurfRad.names[10:28] ;
          
          ####  QC flags description
          
          # A QC flag of zero indicates that the corresponding data point is good, having
          # passed all QC checks. A value greater than 0 indicates that the data failed one
          # level of QC. For example, a QC value of 1 means that the recorded value is
          # beyond a physically possible range, or it has been affected adversely in some manner to produce a
          # knowingly bad value. A value of 2 indicates that the data value failed the second level QC check,
          # indicating that the data value may be
          # physically possible but should be used with scrutiny, and so on. Missing
          # values are indicated by -9999.9 and should always have a QC flag of 1.
          
          
          
          
          
          ###############################################################################################################
          #              Processing the SURFRAD data to the format required by Cycles weather input files
          ###############################################################################################################
          
          
          
          # PP TX TN SOLAR RHX RHN WIND  ; NO PP , temp , solar ? , rh, windspd, 
          
          
          ############################### Reading the Year and Doy of year   #######################################
          
          
          YEAR<-psuSRFRAD.data$year[1] ;
          
          DOY<-psuSRFRAD.data$jday[1]  ;
          
          
          
          ############################### Extract Minimum and maximum temperature #######################################
          
          
          TX<-psuSRFRAD.data[which.max(psuSRFRAD.data[psuSRFRAD.data$temp != -9999.9,"temp"]),"temp"] ;
          
          TN<-psuSRFRAD.data[which.min(psuSRFRAD.data[psuSRFRAD.data$temp != -9999.9,"temp"]),"temp"] ;
          
          
          if (length (TX) == 0) TX<- -9999.9 ;
          
          if (length (TN) == 0) TN<- -9999.9 ;
          
          
          
          # plot(psuSRFRAD.data$dt,psuSRFRAD.data$temp) ;
          # plot(psuSRFRAD.data[psuSRFRAD.data$temp != -9999.9,"dt"],psuSRFRAD.data[psuSRFRAD.data$temp != -9999.9,"temp"]);
          
          
          
          
          ############################### Extract cummulative radiation direct-normal solar (Watts m^-2) ##################
          
          
          # Extracting only positive values
          
          
          
          direct_n_data<-psuSRFRAD.data[psuSRFRAD.data$direct_n != -9999.9, "direct_n"] ;
          direct_n_data_pos<-psuSRFRAD.data[psuSRFRAD.data$direct_n >= 0, "direct_n"] ;
          
          
          dw_solar_data<-psuSRFRAD.data[psuSRFRAD.data$dw_solar != -9999.9, "dw_solar"] ; 
          dw_solar_data_pos<-psuSRFRAD.data[psuSRFRAD.data$dw_solar >= 0, "dw_solar"] ; 
          
          uw_solar_data<-psuSRFRAD.data[psuSRFRAD.data$uw_solar != -9999.9, "uw_solar"] ; 
          uw_solar_data_pos<-psuSRFRAD.data[psuSRFRAD.data$uw_solar >= 0, "uw_solar"] ; 
          
          
          diffuse_data<-psuSRFRAD.data[psuSRFRAD.data$diffuse != -9999.9, "diffuse"] ; 
          diffuse_data_pos<-psuSRFRAD.data[psuSRFRAD.data$diffuse >= 0, "diffuse"] ; 




          # plot(psuSRFRAD.data$dt,psuSRFRAD.data$direct_n) ;
          # 
          # plot(psuSRFRAD.data[psuSRFRAD.data$direct_n != -9999.9,"dt"],psuSRFRAD.data[psuSRFRAD.data$direct_n != -9999.9,"direct_n"]) ;
          # 
          # 
          # plot(psuSRFRAD.data[psuSRFRAD.data$direct_n != -9999.9,"dt"],cumsum(psuSRFRAD.data[psuSRFRAD.data$direct_n != -9999.9,"direct_n"])) ;
          # abline(h=direct_n, col="RED",lwd=5)
          
          
          #Convert radiation data from Watts m^-2 to MJ/m2 
          
          # [watt/m2  = Watt-sec/m2-sec = Joule/m2-sec] * [60sec/min*60min/hr*24hr/day]*[1 MJ /10^6 J]
          
          direct_n<-sum(direct_n_data) * 60 * (24*60/length(direct_n_data))  / 10^6 ;
          direct_n_pos<-sum(direct_n_data_pos) * 60 * (24*60/length(direct_n_data))  / 10^6 ;
          
          
          dw_solar<-sum(dw_solar_data) * 60 * (24*60/length(dw_solar_data))  / 10^6 ;
          dw_solar_pos<-sum(dw_solar_data_pos) * 60 * (24*60/length(dw_solar_data))  / 10^6 ;
          
          uw_solar<-sum(dw_solar_data) * 60 * (24*60/length(dw_solar_data))  / 10^6 ;
          uw_solar_pos<-sum(uw_solar_data_pos) * 60 * (24*60/length(dw_solar_data))  / 10^6 ;
          
          diffuse<-sum(diffuse_data) * 60 * (24*60/length(diffuse_data))  / 10^6 ;
          diffuse_pos<-sum(diffuse_data_pos) * 60 * (24*60/length(diffuse_data))  / 10^6 ;
          
          
          if (length (direct_n) == 0) direct_n<- -9999.9   ;
          
          if (length (direct_n_pos) == 0) direct_n_pos<- -9999.9   ;
          
          
          if (length (dw_solar) == 0) dw_solar<- -9999.9   ;
          
          if (length (dw_solar_pos) == 0) dw_solar_pos<- -9999.9   ;
          
          
          if (length (uw_solar) == 0) uw_solar<- -9999.9   ;
          
          if (length (uw_solar_pos) == 0) uw_solar_pos<- -9999.9   ;
          
          
          if (length (diffuse) == 0) diffuse<- -9999.9   ;
          
          if (length (uw_solar_pos) == 0) uw_solar_pos<- -9999.9   ;
          
          ###############################  Extract Minimum and maximum relative humidity ###########################################
          
          
          
          
          
          # Extracting the missing data marked as -9999.9 
          
          RHX<-psuSRFRAD.data[which.max(psuSRFRAD.data[psuSRFRAD.data$rh != -9999.9,"rh"]),"rh"] ;
          
          RHX_TN<-psuSRFRAD.data[which.min(psuSRFRAD.data[psuSRFRAD.data$temp != -9999.9,"temp"]),"rh"]  ;
          
          RHN<-psuSRFRAD.data[which.min(psuSRFRAD.data[psuSRFRAD.data$rh != -9999.9,"rh"]),"rh"] ;
          
          RHN_TX<-psuSRFRAD.data[which.max(psuSRFRAD.data[psuSRFRAD.data$temp != -9999.9,"temp"]),"rh"] ;
          
          
          if (length (RHX) == 0) RHX<- -9999.9 ;
          
          if (length (RHX_TN) == 0) RHX_TN<- -9999.9 ;
          
          if (length (RHN) == 0) RHN<- -9999.9 ;
          
          if (length (RHN_TX) == 0) RHN_TX<- -9999.9 ;
          
          # plot(psuSRFRAD.data$dt,psuSRFRAD.data$rh) ;
          # plot(psuSRFRAD.data[psuSRFRAD.data$rh != -9999.9,"dt"],psuSRFRAD.data[psuSRFRAD.data$rh != -9999.9,"rh"]) ;
          # 
          
          
          
          
          ############################### Extract average wind speed ################################################################
          
          
          
          
          
          # Extracting the missing data marked as -9999.9 
          
          WIND<-mean(psuSRFRAD.data[psuSRFRAD.data$windspd != -9999.9,"windspd"]) ;
          
          # plot(psuSRFRAD.data$dt,psuSRFRAD.data$windspd) ;
          # 
          # plot(psuSRFRAD.data[psuSRFRAD.data$windspd != -9999.9,"dt"],psuSRFRAD.data[psuSRFRAD.data$windspd != -9999.9,"windspd"])
          # abline(h=WIND, col="RED",lwd=5)
          
          
           if (length (WIND) == 0) WIND<- -9999.9 ;
          
          
          ############################### Collect the data in a data frame and write it to the SurfradData.txt data file ############
          
          
          
          SurfradData<-data.frame(YEAR, DOY , TX , TN ,  dw_solar, dw_solar_pos , uw_solar, uw_solar_pos , direct_n , direct_n_pos , diffuse , diffuse_pos , RHX , RHX_TN , RHN , RHN_TX ,  WIND)  ;
          
          
          
          SurfradData[,c("TX" , "TN" , "dw_solar", "dw_solar_pos" , "uw_solar", "uw_solar_pos" , "direct_n" , "direct_n_pos" , "diffuse" , "diffuse_pos" , "RHX" , "RHX_TN" , "RHN" ,"RHN_TX" , "WIND")] <-signif(SurfradData[,c("TX" , "TN" , "dw_solar", "dw_solar_pos" , "uw_solar", "uw_solar_pos" , "direct_n" , "direct_n_pos" , "diffuse" , "diffuse_pos" , "RHX" , "RHX_TN" , "RHN" ,"RHN_TX" , "WIND")],5)
          
          write.table(SurfradData , file="SurfradData.txt" , append=T , row.names = F, sep="\t", quote = F, col.names = F ) ;
          
          remove.files<-ls()[!ls() %in% c("j", "i" ,"SurfRad.names","List_years","List_files", "PennStSurfrad.url","TimeStart")]
          
          rm(list=remove.files)
          
     }
 
     
     rm(j)    
}

rm(i)

SURFRAD_DATA<-read.table("SurfradData.txt", skip=4, header=T, as.is=T) ;


SURFRAD_DATA$DATE<-as.Date(paste0(as.character(SURFRAD_DATA$YEAR), ":" , as.character(SURFRAD_DATA$DOY)),  "%Y:%j") ;


plot(SURFRAD_DATA$DATE, SURFRAD_DATA$TX,col="RED")  ;

plot(SURFRAD_DATA$DATE, SURFRAD_DATA$TX,col="RED", ylim=c(0,45)) ;
points(SURFRAD_DATA$DATE, SURFRAD_DATA$TN,col="BLUE")   ;

plot(SURFRAD_DATA$DATE, SURFRAD_DATA$SOLAR,col="RED")  ;
points(SURFRAD_DATA$DATE, SURFRAD_DATA$SOLAR_POS,col="BLUE")  ;

plot(SURFRAD_DATA$DATE, SURFRAD_DATA$WIND,col="BLUE")  ;

plot(SURFRAD_DATA$DATE, SURFRAD_DATA$RHX,col="RED")  ;
plot(SURFRAD_DATA$DATE, SURFRAD_DATA$RHX,col="RED",ylim=c(0,120))  ;
points(SURFRAD_DATA$DATE, SURFRAD_DATA$RHX_TN,col="BLUE")  ;

plot(SURFRAD_DATA$DATE, SURFRAD_DATA$RHN,col="RED")   ;
plot(SURFRAD_DATA$DATE, SURFRAD_DATA$RHN,col="RED",ylim=c(-10,100))   ;
points(SURFRAD_DATA$DATE, SURFRAD_DATA$RHN_TX,col="BLUE")   ;


TimeEnd<-Sys.time()    ;

CPUTime<-TimeEnd-TimeStart    ;


CPUTime
