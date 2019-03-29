#
#############################################################################################################################
#
#  Program to extract Weather Data from the SURFRAD Network weather station in Penn State, Pennsylvania
#  https://www.esrl.noaa.gov/gmd/grad/surfrad/pennstat.html
#  ftp://aftp.cmdl.noaa.gov/data/radiation/surfrad/Penn_State_PA/README
#
#  Felipe Montes,  2017/03/07
#
##############################################################################################################################






###############################################################################################################
#                          Loading Packages and setting up working directory                        
###############################################################################################################



#  Tell the program where the package libraries are  #####################


.libPaths("C:/Felipe/R_Library/library")

#  Set Working directory


setwd("C:/Felipe/OrganicTransitions_N2OROSE/CyclesSimulation/RoseRCodeScripts/NOA_SURFRAD_DATA") ; 





###############################################################################################################
#                         Loading data from a daily data file .dat from the Penn State
#                             SURFRAD fttp archive
###############################################################################################################

## Create the URL's path for the directory to be added to the file

PennStSurfrad.url<-"ftp://aftp.cmdl.noaa.gov/data/radiation/surfrad/Penn_State_PA/2016/"   ;

FileName<-"psu16001.dat" ;  


### Read the station name, latitude, Long, elevation above sea levelpsu10001.data

psu10001.station.name<-readLines(paste0(PennStSurfrad.url,FileName),n=1)  ;

psu10001.station.data<-read.table(paste0(PennStSurfrad.url,FileName), skip= 1 ,nrows=1, header=F, as.is= T)  ;

names(psu10001.station.data)<-c("LATITUDE", "LONGITUDE" , "ALTITUDE" , "meters","version" ,"version No") ;




### write the Station name and data to the file where the data formated for cycles will be stored


write(psu10001.station.name, file="SurfradData.txt") ;

write(paste(names(psu10001.station.data)[1],psu10001.station.data[1]),file="SurfradData.txt", append=T) ;

write(paste(names(psu10001.station.data)[3],psu10001.station.data[3]),file="SurfradData.txt", append=T) ;

write(c("SCREENING_HEIGHT  10"),file="SurfradData.txt", append=T);



### Define and write the column headings for the data that is to be stored in the table according to the format needed for Cycles

YEAR = 987654321 ; 

DOY = 987654321  ;

TX = 987654321  ;

TN = 987654321  ;

SOLAR = 987654321  ; 

RHX = 987654321  ;

RHN = 987654321  ;

WIND = 987654321  ;


write.table(data.frame(YEAR, DOY , TX , TN , SOLAR , RHX , RHN , WIND)[F,] , file="SurfradData.txt" , append=T , row.names = F, sep="\t", quote = F ) ;

#### Read one day of data .dat file from the SURFRAD URl 


psu10001.data<-read.table(paste0(PennStSurfrad.url,FileName), skip=2, header=F, as.is= T)   ;


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


### Adding quality control flags -QC- names to he appropriate columns:


names(psu10001.data)[1:9]<-SurfRad.names[1:9]   ;
names(psu10001.data)[seq(10,48,2)]<-c("QC") ;
names(psu10001.data)[seq(11,47,2)]<-SurfRad.names[10:28] ;

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


YEAR<-psu10001.data$year[1] ;

DOY<-psu10001.data$jday[1]  ;



############################### Extract Minimum and maximum temperature #######################################

# Extracting the missing data marked as -9999.9 



TX<-psu10001.data[which.max(psu10001.data[psu10001.data$temp != -9999.9,"temp"]),"temp"] ;

TN<-psu10001.data[which.min(psu10001.data[psu10001.data$temp != -9999.9,"temp"]),"temp"] ;

plot(psu10001.data$dt,psu10001.data$temp) ;
plot(psu10001.data[psu10001.data$temp != -9999.9,"dt"],psu10001.data[psu10001.data$temp != -9999.9,"temp"]);




############################### Extract cummulative radiation direct-normal solar (Watts m^-2) ##################


# Extracting the missing data marked as -9999.9 

direct_n<-sum(psu10001.data[psu10001.data$direct_n != -9999.9,"direct_n"]) ;

plot(psu10001.data$dt,psu10001.data$direct_n) ;

plot(psu10001.data[psu10001.data$direct_n != -9999.9,"dt"],psu10001.data[psu10001.data$direct_n != -9999.9,"direct_n"]) ;


plot(psu10001.data[psu10001.data$direct_n != -9999.9,"dt"],cumsum(psu10001.data[psu10001.data$direct_n != -9999.9,"direct_n"])) ;
abline(h=direct_n, col="RED",lwd=5)


#Convert radiation data from Watts m^-2 to MJ/m2 

# [watt/m2  = Watt-sec/m2-sec = Joule/m2-sec] * [60sec/min*60min/hr*24hr/day]*[1 MJ /10^6 J]

SOLAR<-direct_n*(60*60*24)/(10^6) ;






###############################  Extract Minimum and maximum relative humidity ###########################################





# Extracting the missing data marked as -9999.9 

RHX<-psu10001.data[which.max(psu10001.data[psu10001.data$rh != -9999.9,"rh"]),"rh"] ;

RHN<-psu10001.data[which.min(psu10001.data[psu10001.data$rh != -9999.9,"rh"]),"rh"] ;


plot(psu10001.data$dt,psu10001.data$rh) ;
plot(psu10001.data[psu10001.data$rh != -9999.9,"dt"],psu10001.data[psu10001.data$rh != -9999.9,"rh"]) ;





############################### Extract average wind speed ################################################################





# Extracting the missing data marked as -9999.9 

WIND<-mean(psu10001.data[psu10001.data$windspd != -9999.9,"windspd"]) ;

plot(psu10001.data$dt,psu10001.data$windspd) ;

plot(psu10001.data[psu10001.data$windspd != -9999.9,"dt"],psu10001.data[psu10001.data$windspd != -9999.9,"windspd"])
abline(h=WIND, col="RED",lwd=5)




# Collect the data in a data frame and write it to the SurfradData.txt data file

SurfradData<-data.frame(YEAR, DOY , TX , TN , SOLAR , RHX , RHN , WIND)  ;


SurfradData[,c("TX" , "TN" , "SOLAR" , "RHX" , "RHN" , "WIND")] <-signif(SurfradData[,c("TX" , "TN" , "SOLAR" , "RHX" , "RHN" , "WIND")],5)

write.table(SurfradData , file="SurfradData.txt" , append=T , row.names = F, sep="\t", quote = F, col.names = F ) ;









