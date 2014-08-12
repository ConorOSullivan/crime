
load('just_dates.R') # gets justdates
probs<-read.table('/Users/conorosullivan/Documents/fifth_module/wise/crime/final_predictions/predicted_probabilities.txt')
nebs <- rep(c('BAYVIEW',"CENTRAL","INGLESIDE","MISSION","NORTHERN","PARK","RICHMOND",'SOUTHERN','TARAVAL',"TENDERLOIN"),each=99597)
# probs <- cbind(probs,PdDistrict=nebs)
ps<-read.csv('cat_predicted_probabilities.txt',sep=' ',header=F)
cats<-c( 'ARSON','ASSAULT','BAD CHECKS','BRIBERY','BURGLARY','DISORDERLY CONDUCT','DRIVING UNDER THE INFLUENCE','DRUG/NARCOTIC','DRUNKENNESS','EMBEZZLEMENT','EXTORTION','FAMILY OFFENSES','FORGERY/COUNTERFEITING','FRAUD','GAMBLING','KIDNAPPING','LARCENY/THEFT','LIQUOR LAWS','LOITERING','MISSING PERSON','NON-CRIMINAL','None','OTHER OFFENSES','PORNOGRAPHY/OBSCENE MAT','PROSTITUTION','ROBBERY','RUNAWAY','SEX OFFENSES, FORCIBLE','SEX OFFENSES, NON FORCIBLE','STOLEN PROPERTY','SUICIDE','SUSPICIOUS OCC','TRESPASS','VANDALISM','VEHICLE THEFT','WARRANTS','WEAPON LAWS')
colnames(ps)[1:37]<-cats

require("rgdal") # requires sp, will use proj.4 if installed
require("maptools")
require("ggplot2")
require("plyr")
library(ggplot2)
utah = readOGR(dsn='/Users/conorosullivan/Documents/fifth_module/wise/crime/crime_app/sfpd_districts/.',layer="sfpd_districts")
utah@data$id = rownames(utah@data)
utah.points = fortify(utah, region="id")
utah.df = join(utah.points, utah@data, by="id")

thesize = 16

get_rows<-function(inputdate,inputhr) {
  date <- as.character(strptime(paste(inputdate,inputhr),format="%Y-%m-%d %H"))
  daterows <- which(date == justdates)
  daterows <- c(sapply(daterows, function(x){x + c(0:9)}))
  daterows
}

output_prob<-function(inputdate,inputhr,inputshift,neighborhood) {
  rows <- get_rows(inputdate, inputhr)
  offset <- seq(0,90,by=10)
  offset <- offset + inputshift
  probdata <- data.frame(probs=probs[rows[offset],1],PdDistrict=c('BAYVIEW',"CENTRAL","INGLESIDE","MISSION","NORTHERN","PARK","RICHMOND",'SOUTHERN','TARAVAL',"TENDERLOIN"))
  return(as.numeric(probdata[probdata$PdDistrict == neighborhood,1]))
}

get_table<-function(r) {
  y<-ps[r,]
  top<-y[order(y,decreasing=T)]
  nms<-colnames(top)
  nonzero<-which(top!=0 & nms != 'None')
  thedf <- data.frame(Category=nms[nonzero],Probability=unlist(c(top[nonzero])))
  rownames(thedf) <- NULL
  return(thedf[1:5,])
}


output_cat_table<-function(inputdate,inputhr,inputshift,neighborhood){
  rows <- get_rows(inputdate, inputhr)
  offset <- seq(0,90,by=10)
  offset <- offset + inputshift
  thisnebrow <- which(neighborhood == c('BAYVIEW',"CENTRAL","INGLESIDE","MISSION","NORTHERN","PARK","RICHMOND",'SOUTHERN','TARAVAL',"TENDERLOIN"))
  out_table <- get_table(thisnebrow)
}
library(scales)
plotit<-function(theindate,theinhour,theinshift,neighborhood){
  districts<-c('BAYVIEW',"CENTRAL","INGLESIDE","MISSION","NORTHERN","PARK","RICHMOND",'SOUTHERN','TARAVAL',"TENDERLOIN")
  theprobability <- output_prob(theindate, theinhour, theinshift, neighborhood)
#   thisdf <- utah.df[utah.df$DISTRICT == neighborhood,]
  thisdf <- utah.df
  cols <- rep('grey',10)
  cols[which(neighborhood == districts)] <- 'black'
  coldf <- data.frame(DISTRICT = districts, cols=cols)
  print(cols)
  thisdf <- join(thisdf,coldf)
#   browser()
  p<-ggplot(thisdf) +
    aes(long,lat,group=group,fill=DISTRICT) + 
    geom_polygon() +
    scale_fill_manual(values=cols) +
    geom_path(color="white") +
    coord_equal() +
    ggtitle('Probability of Crime by Police District') +
    
    theme(axis.ticks.x = element_blank(),
          axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          plot.title = element_text(size=rel(2)),
          legend.position = "none",
          axis.ticks.y = element_blank()) +
    xlab('') + ylab('') + 
    annotate('text',x=mean(thisdf$long),
             y=mean(thisdf$lat),
             label=paste(theprobability),
             size=16)
  show(p)
}

plotneib <- function(inputhr,inputday,inputshifthr){
  
}


shinyServer(function(input,output) {   
  
  output$cityPlot <- renderPlot({
    chardate <- as.character(unlist(input$caldate))
#     numhr <- as.numeric(input$hourstart)
    capneib <- toupper(input$selectNeighborhoods)
#     theplot <- plotit(chardate,numhr,input$shifthr,'MISSION')
    theplot <- plotit(unlist(chardate),as.numeric(input$hourstart),input$shifthr,capneib)
    print(theplot)
  }
    )
  
#   output$cityPlot <- renderPlot({
#     b<-sapply(c(input$selectNeighborhoods,input$caldate),class)
#     a <- data.frame(x=c(1,2),y=c(1,2),z=b)
#     print(ggplot(a) +
#       geom_text(aes(x=x,y=y,label=z)))
# #     g <- plotsimp(input$caldate,input$hourstart,input$shifthr,input$selectNeighborhoods)
# #     print(g)
#   })

  
  output$neibTable <- renderTable({
    chardate <- as.character(unlist(input$caldate))
    capneib <- toupper(input$selectNeighborhoods)
    aa <- output_cat_table(chardate,as.numeric(input$hourstart),input$shifthr,capneib)
    return(aa)
  },
  include.rownames = FALSE
    )
  
  })