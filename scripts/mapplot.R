map_plot <- function(mapdata, coronavirusdata, type, grouping, trans = "log10") {
  
  current_date <- max(coronavirusdata$date, na.rm=TRUE)

  coronavirusdata <-
    coronavirusdata %>%
    filter(type == {{type}})%>%
    group_by(!!(grouping)) %>%
    summarize(cases = sum(cases, na.rm=TRUE))
  
    out <- ggplot() +
      geom_sf(data = mapdata, fill = "lightgrey") +
      geom_sf(data = coronavirusdata, mapping = aes(fill = cases)) +
      scale_fill_viridis_c(trans = trans, na.value = "white") +
      theme_minimal(base_size = 14) +
      labs(fill = paste0(stringr::str_to_title(type), "\nCases")) +
      coord_sf() +
      ggtitle("",
        subtitle = paste0("Totals current to ", current_date)) 

    
    return(out)
}
