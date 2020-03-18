total_plot_ts <- function(dataset, type, title = ""){
  
  ggplot(dataset,
         aes(x = date, y = total_cases)) +
    geom_line(size = 1.3) +
    theme_minimal(base_size = 14) +
    ylab(paste0("Total ", stringr::str_to_title(type), "\nCases")) +
    ggtitle(title,
            subtitle = paste0("Current to ", max(dataset$date, na.rm=TRUE))) +
    theme(plot.title.position = "plot") +
    xlab("")
  
}