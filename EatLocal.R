# add lat long locations to CSA & FarmersMarkets files

get_csa_locations <- function() {
    csa <- read.csv("CSA.csv", stringsAsFactors = FALSE)
    
    addresses = paste0(csa$HQ_ST, csa$HQ_City, csa$HQ_State, csa$HQ_Zip, ", United States")
    
    #use the gecode function to query google servers
    geo_reply = geocode(addresses, output='latlon', messaging = TRUE)
    
    csa <- cbind(csa, geo_reply$lat, geo_reply$lon)
    names(csa)[ncol(csa)-1]<-"lat"
    names(csa)[ncol(csa)]<-"lon"
    
    write.csv(csa,file="CSA_loc.csv")
}

tidy_market_data <- function(infile="FarmersMarkets.csv") {
    library(plyr)
    
    data <- read.csv(infile, stringsAsFactors = FALSE)
    addresses = paste0(data$street, data$city, data$state, data$zip, ", United States")
    
    # remove leading #'s
    lead_pound <- substring(addresses,1,1) == "#"
    addresses[lead_pound] <- str_sub(addresses[lead_pound], 2)
    
    names(data)[names(data)=="x"] <- "lon"
    names(data)[names(data)=="y"] <- "lat"
    
    #finally write it all to the output files
    saveRDS(data, paste0(infile ,"_geocoded.rds"))
    write.table(data, file=paste0(infile ,"_loc.csv"), sep=",", row.names=FALSE)
}

#define a function that will process googles server responses for us.
getGeoDetails <- function(address){   
    #use the gecode function to query google servers
    geo_reply = geocode(address, output='all', messaging=TRUE, override_limit=TRUE)
    #now extract the bits that we need from the returned list
    answer <- data.frame(lat=NA, long=NA, accuracy=NA, formatted_address=NA, address_type=NA, status=NA)
    answer$status <- geo_reply$status
    
    #if we are over the query limit - want to pause for an hour
    while(geo_reply$status == "OVER_QUERY_LIMIT"){
        print("OVER QUERY LIMIT - Pausing for 1 hour at:") 
        time <- Sys.time()
        print(as.character(time))
        Sys.sleep(60*60)
        geo_reply = geocode(address, output="all", messaging=TRUE, override_limit=TRUE)
        answer$status <- geo_reply$status
    }
    
    #return Na's if we didn't get a match:
    if (geo_reply$status != "OK"){
        return(answer)
    }   
    #else, extract what we need from the Google server reply into a dataframe:
    answer$lat <- geo_reply$lat
    answer$long <- geo_reply$lon   

    return(answer)
}

get_us_map <- function() {
    library(ggmap)
    us.map <- get_map(location = 'United States', zoom = 4) # zoom 0-21
    save(us.map,file="us.rda")
}

plot_eat_local_map <- function(date, csa=TRUE, fm=TRUE) {
    library(ggplot2)
    library(ggmap)
    library(stringr)
    
    load("us.rda")
    map <- ggmap(us.map, extent = "device", legend = "topleft")
    cur_date <- as.Date(date)
    
    if (fm) {
        date_range <- str_split_fixed(fm_loc$Season1Date,"to",n=2)
        start <- as.Date(date_range[,1],format="%m/%d/%y")
        end <- as.Date(date_range[,2],format="%m/%d/%y")
        start<-format(start, format="%m-%d")
        end<-format(end, format="%m-%d")
        cur_date<-format(cur_date, format="%m-%d")
        
        cur_fm <- subset(fm_loc, cur_date>start & cur_date<end)
        map <- map +
            geom_point(aes(x = lon, y = lat), data = cur_fm, colour="orange") 
    }
    
    if (csa) {
        xlt <- as.POSIXlt(date)
        month <- month.abb[xlt$mon+1]
        cur_csa <- subset(csa_loc, grepl(month,csa_loc$Available_Months))
        map <- map +
            geom_point(aes(x = lon, y = lat), data = cur_csa, colour="#006400") +
            scale_color_manual(values = c("#006400", "orange"))
    }
    

    map
}
