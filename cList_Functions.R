# Create URL Search Query -------------------------------------------------
SearchQuery <- function(area, search_term)
{ 
  search_term = gsub(" ", "+",search_term)
  TextToSearch = sprintf("https://%s.craigslist.ca/search/msa?query=%s", trimws(tolower(area)), search_term)
  return(TextToSearch)
}


# Parse HTML to return Variables ------------------------------------------
parse_html = function(html_rows){
  datetime = html_attr(html_nodes(html_rows, ".result-date"), "datetime")
  posttitle = html_text(html_nodes(html_rows, ".result-title"))
  url = html_attr(html_nodes(html_rows, ".result-title"), "href")
  
  df = data.frame(datetime, posttitle, url)
  
  for (a in 1:nrow(df)){
    if(length(html_text(html_nodes(html_rows[a], ".result-price"))) == 1) {
      df$price[a] = html_text(html_nodes(html_rows[a], ".result-price"))
    } else {df$price[a] = 0}
  }
  return(df)
}

parse_page = function(locale.target, searchquery.target){
  result_rows = html_children(read_html(SearchQuery(locale.target, searchquery.target))) %>% html_nodes(".result-row") %>% html_children()
  result_rows = result_rows[grepl("result-info", result_rows)]
  if (length(result_rows) == 0) {return(NULL)} else {
    for (ii in 1:length(result_rows)){
      if(ii == 1){
        df.output = parse_html(result_rows[ii])
      } else {df.output = rbind(df.output, parse_html(result_rows[ii]))}
  } 
  }
  df.output$locale = locale.target
  return(df.output)
  }

