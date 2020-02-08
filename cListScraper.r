library(rvest)
library(RMySQL)
library(dplyr)
source("cList_FunctionsV3.r")


# Setup DB Connection and Key Variables -----------------------------------

mydb = dbConnect(MySQL(), user='user', password = 'pwd', dbname='dbname', host='hostname')
locales = c("toronto", "calgary", "edmonton", "vancouver", "winnipeg", "halifax", "barrie", "kingston", "london", "peterborough", "montreal")
search_query = "Fender Jazzmaster"


# Scrape Data from Each Locale --------------------------------------------
for (locales.index in 1:length(locales)){
  if (locales.index == 1){
    df.final = parse_page(locales[locales.index], search_query)
  } else {
   df.final = rbind(df.final, parse_page(locales[locales.index], search_query)) 
  }
}


# Clean Data Set ----------------------------------------------------------
# Dedupe
df.final = df.final[!duplicated(df.final$posttitle),]
# Clean Cost
df.final$price = as.numeric(gsub("\\$", "", df.final$price))
df.final = df.final[df.final$price > 0, ]
df.final = df.final[grepl(toupper(gsub(" ", "|", search_query)), toupper(df.final$posttitle)), ]
# Remove outliers
df.final = df.final[df.final$price > 10,]
df.final = df.final[df.final$price < median(df.final$price) + (sd(df.final$price)*3),]
df.final$searchquery = search_query
# Clean out apostrophes from posttitle
df.final$posttitle = gsub("\\'|,", "", df.final$posttitle)

df.final$datetime = as.character(df.final$datetime)
df.final$posttitle = as.character(df.final$posttitle)
df.final$url = as.character(df.final$url)
df.final$locale = as.character(df.final$locale)
df.final$searchquery = as.character(df.final$searchquery)



# Insert in DB ------------------------------------------------------------

for (i in 1:nrow(df.final)){
  dbSendQuery(mydb, 
              paste0("INSERT INTO clist VALUES ('", paste(df.final[i,], collapse = "', '", sep =""), "')")
  )
}

dbDisconnect(mydb)

