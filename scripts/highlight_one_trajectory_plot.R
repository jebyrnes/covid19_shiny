highlight_one_trajectory_plot <- function(dataset, one_region, select_col,
                                          title_start = "",
                                          nochina=FALSE , trans="identity"){
  
  one_region_data <- dataset %>%
    filter(!!(select_col) == {{one_region}})

  if(nochina){
    one_region_data <- one_region_data %>% filter(Country.Region != "China")
  }
  
  ggplot(dataset,
         aes(x = date, y = total_cases, group = !!(select_col))) +
    geom_line(color = "darkgrey")+
    geom_line(data = one_region_data,
              color = "blue", size = 1.5)+
    theme_minimal(base_size = 14) +
    ylab("Total Confirmed\nCases") +
    ggtitle(paste0(title_start, ", ", one_region, " Highlighted"),
            subtitle = paste0("Current to ", max(dataset$date, na.rm=TRUE))) +
    theme(plot.title.position = "plot")+
    xlab("") +
    scale_y_continuous(trans=trans) +
     scale_x_date(date_breaks = "1 week", date_labels = "%b %d")
  
}
