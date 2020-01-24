require(vegan)
require(RPostgreSQL)
require(fields)
options(warn=0)  #don't let warn=2 hang around - takes warning about R version into an error
require(reshape2)
require(plyr)
require(Hmisc)
require(proj4)
require(rgdal)
require(rworldmap)
require(GISTools)
require(data.table)
require(glm2)
require(irr)
require(car)

## Extract occurrence data by provider in long format ##
geteteoccur<-function(provider) {
  drv=dbDriver("PostgreSQL")
  con=dbConnect(drv,dbname=dbname,user=user, password=password, host=host, port=port) #Removed connection details
  qry=paste("select o.occurid, o.sitekey, s.sitename, o.speciesid, o.observed, s.sid, s.timeybp, s.datasetname, s.latitude, s.longitude, s.duration, s.spaceextent, d.provider from occurrence as o ,sites as s,dataset as d where o.sitekey=s.SiteKey AND s.DatasetName=d.DatasetName AND d.Provider='",provider,"';",sep="")
  res=dbSendQuery(con,qry)
  dt=fetch(res,-1)
  dbDisconnect(con)
  #dt = dt[,c(1:4, 7:12)]
  return(dt)
}

geteteoccurdataset<-function(dataset) {
  drv=dbDriver("PostgreSQL")
  con=dbConnect(drv,dbname=dbname,user=user, password=password, host=host, port=port) #Removed connection details
  qry=paste("select o.occurid, o.sitekey, s.sitename, o.speciesid, o.observed, s.sid, s.timeybp, s.datasetname, s.latitude, s.longitude, s.duration, s.spaceextent from occurrence as o ,sites as s where o.sitekey=s.SiteKey AND s.DatasetName='", dataset,"';",sep="")
  res=dbSendQuery(con,qry)
  dt=fetch(res,-1)
  dbDisconnect(con)
  #dt = dt[,c(1:4, 7:12)]
  return(dt)
}

### Extract site coordinates by provider ###
getlatlon<-function(provider) {
  drv=dbDriver("PostgreSQL")
  con=dbConnect(drv,dbname=dbname,user=user, password=password, host=host, port=port) #Removed connection details
  qry=paste("select sitekey, sitename, latitude, longitude from sites as s,dataset as d where s.DatasetName=d.DatasetName AND d.Provider='",provider,"';",sep="")
  res=dbSendQuery(con,qry)
  dt=fetch(res,-1)
  dbDisconnect(con)
  return(dt)
}

###Extract site ages in ybp####
getages<-function(provider){
  drv=dbDriver("PostgreSQL")
  con=dbConnect(drv,dbname=dbname,user=user, password=password, host=host, port=port) #Removed connection details
  qry=paste("select sitekey, timeybp from sites as s,dataset as d where s.DatasetName=d.DatasetName AND d.Provider='",provider,"';",sep="")
  res=dbSendQuery(con,qry)
  dt=fetch(res,-1)
  dbDisconnect(con)
  return(dt)
}

##Extract site trait matrix###
#NOTE: returns values formatted as character strings.  Values must be converted to numeric before use in analyses
getsitetraits<-function(provider){
  drv=dbDriver("PostgreSQL")
  con=dbConnect(drv,dbname=dbname,user=user, password=password, host=host, port=port) #Removed connection details
  qry=paste("select t.sitekey, variablename, numvar, discvar from sitetrait as t, sites as s, dataset as d where t.sitekey = s.sitekey AND s.DatasetName = d.DatasetName AND d.Provider='", provider, "';", sep="")
  res=dbSendQuery(con, qry)
  dt=fetch(res, -1)
  #dt = dbReadTable(con, 'sitetrait') 
  dbDisconnect(con)
  dt$discvar[is.na(dt$discvar)]=''
  dt$numvar[is.na(dt$numvar)]=''
  dt$numvar = paste(dt$discvar, dt$numvar)
  dt = dcast(dt,sitekey~variablename,value.var='numvar' )
  return(dt)
}


#Extract species trait matrix ###
getspptraits<-function(provider){
  drv=dbDriver("PostgreSQL")
  con=dbConnect(drv,dbname=dbname,user=user, password=password, host=host, port=port) #Removed connection details
  qry=paste("select t.speciesid, traitname, numvalue, discvalue from speciestrait as t, species as p, occurrence as o, sites as s, dataset as d where t.speciesid = p.speciesid AND p.speciesid = o.speciesid AND o.sitekey = s.sitekey AND s.datasetname= d.datasetname AND d.Provider='", provider, "';", sep="")
  res=dbSendQuery(con, qry)
  dt=fetch(res, -1)
  dbDisconnect(con)
  dt$discvalue[is.na(dt$discvalue)]=''
  dt$numvalue[is.na(dt$numvalue)]=''
  dt$numvalue = paste(dt$discvalue, dt$numvalue)
  dt$numvalue = as.factor(dt$numvalue)
  dt = unique(dt)
  dt = dcast(dt,speciesid~traitname,value.var='numvalue')
  return(dt)
}


### Create your own query ###
sql2df<-function(qry,maxrows=100000) {
  drv=dbDriver("PostgreSQL")
  con=dbConnect(drv,dbname=dbname,user=user, password=password, host=host, port=port) #Removed connection details
  res=dbSendQuery(con,qry)
  nrows=dbGetRowCount(res)
  if (nrows>maxrows) {
    warning('More than maxrows rows from query. Result truncated to maxrows records')
    nrowfetch=maxrows
  } else {
    nrowfetch=-1  # fetch them all
  }
  dt=fetch(res,nrowfetch)
  dbDisconnect(con)
  return(dt)
}


unmelt2specXsite<-function(df) {
  #require(reshape2)
  ary=acast(df,speciesid~sitekey,value.var="observed", fun.aggregate = mean)
  return(ary)
}

unmelt2specXtime<-function(df){ ## unmelts by time bin
  ary=acast(df,speciesid~timebins,value.var="observed", fun.aggregate = sum)
  return(ary)
}

unmelt2specXtimeybp<-function(df){ ## unmelts by timeybp
  ary=acast(df,speciesid~timeybp,value.var="observed", fun.aggregate = sum)
  return(ary)
}

getTable = function(tablename)
{
  drv=dbDriver("PostgreSQL")
  con=dbConnect(drv,dbname=dbname,user=user, password=password, host=host, port=port) #Removed connection details
  table = dbReadTable(con, tablename)
  dbDisconnect(con)
  return(table)
}

pa2csv <- function(provider){
  # retrieves presence-absence tables by timebin for one provider and writes them to csv files in the current working directory.
  ds <- sql2df(paste("select datasetname from dataset where provider = '", provider, "'", sep = ''))
  temp = numeric()
  for(i in 1:nrow(ds)) 
  {
    temp = geteteoccurdataset(ds[i,])
    temp = unmelt2specXsite(temp)
    write.csv(temp, file = ds[i,])
  }
}


pa2list <- function(provider){
  # retrieves presence-absence tables by timebin for one provider and returns them in a list named by dataset
  ds <- sql2df(paste("select datasetname from dataset where provider = '", provider, "'", sep = ''))
  pas <- list()
  temp = numeric()
  for(i in 1:nrow(ds)) 
  {
    temp = geteteoccurdataset(ds[i,])
    temp = unmelt2specXsite(temp)
    pas[[i]] <- temp
  }
  names(pas) <- ds
  return(pas)
}


#species ID to binomial table:

sppIDkey <- function(provider){
  spptable = sql2df(paste("select s.speciesid, s.binomial from species as s, occurrence, sites, dataset WHERE s.speciesid=occurrence.speciesid AND occurrence.sitekey=sites.SiteKey AND sites.datasetname=dataset.datasetname AND dataset.provider='", provider,"'", sep = ""))
  return(unique(spptable))
}
