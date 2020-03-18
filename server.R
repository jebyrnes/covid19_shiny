#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(coronavirus)
library(ggplot2)
library(dplyr)
library(sf)
library(ggrepel)
library(rnaturalearth)
library(rnaturalearthhires)
library(tigris)


#helper functions
source("./scripts/mapplot.R")
source("./scripts/total_plot_ts.R")
source("./scripts/highlight_one_trajectory_plot.R")

#Load and prep data
world_map <- coronavirus::world_map
coronavirus_sf <- update_coronavirus_raw(returnclass = "sf")
coronavirus_sf_polys <- coronavirus_sf %>% st_join(coronavirus::world_map, .)

#USA
us_map <- ne_states(country = "United States of America", returnclass = "sf") %>%
    rename(type_of_area = type)

usa_coronavirus_sf_polys <- coronavirus_sf %>%
    filter(Country.Region=="United States of America") %>%
    st_join(us_map, .)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

    
    output$worldPlot <- renderPlot({
        
        map_plot(world_map, coronavirus_sf_polys, input$type, quo(Country.Region))
        
    })
    output$worldTSPlot <- renderPlot({
        
        world_coronavirus_ts <- coronavirus_sf %>%
            filter(type==input$type) %>%
            group_by(date) %>%
            summarize(cases = sum(cases)) %>%
            ungroup() %>%
            arrange(date) %>%
            mutate(total_cases = cumsum(cases))
        
        total_plot_ts(world_coronavirus_ts, input$type, title = "World Trajectory")
            
        
    })
    
    output$countryTSPlot <- renderPlot({
        
        country_coronavirus_ts <- coronavirus_sf %>%
            filter(type==input$type) %>%
            group_by(Country.Region, date) %>%
            summarize(cases = sum(cases)) %>%
            ungroup() %>%
            arrange(date) %>%
            group_by(Country.Region) %>%
            mutate(total_cases = cumsum(cases)) %>%
            ungroup()
        
        
        highlight_one_trajectory_plot(country_coronavirus_ts, input$countries, 
                                      quo(Country.Region),
                                      title_start = "All Countries, log scale",
                                      nochina=FALSE , trans="log10")
        
    })
    
    output$usPlot <- renderPlot({
        map_plot(us_map %>% filter(!(name %in% c("Alaska", "Hawaii"))), 
                 usa_coronavirus_sf_polys%>% filter(!(name %in% c("Alaska", "Hawaii"))), 
                 input$typeus, 
                 quo(name))
        
        
    })
    
    output$usTSPlot <- renderPlot({
       us_coronavirus_ts <- usa_coronavirus_sf_polys %>%
            as_tibble() %>%
            filter(type==input$typeus) %>%
            group_by(date) %>%
            summarize(cases = sum(cases)) %>%
            ungroup() %>%
            arrange(date) %>%
            mutate(total_cases = cumsum(cases))
        
        total_plot_ts(us_coronavirus_ts, input$typeus, title = "US Over Time")
        
    })
    
    output$usStateTSPlot <- renderPlot({
        state_coronavirus_ts <- usa_coronavirus_sf_polys %>%
            as_tibble() %>%
            filter(type==input$typeus) %>%
            group_by(name, date) %>%
            summarize(cases = sum(cases)) %>%
            ungroup() %>%
            arrange(date) %>%
            group_by(name) %>%
            mutate(total_cases = cumsum(cases)) %>%
            ungroup()
        
        
        highlight_one_trajectory_plot(state_coronavirus_ts, input$states, 
                                      quo(name),
                                      title_start = "All States over time",
                                      nochina=FALSE , trans="identity")
        
    })
    
    #the dynamically changing map of counties
    state_map <- reactive({
        st_as_sf(counties(input$states_for_counties, cb = TRUE)) %>%
            st_transform(crs = st_crs(usa_coronavirus_sf_polys))
    })
    
    state_coronavirus <- reactive({
        coronavirus_sf %>%
            st_join(state_map(), .)
    })
    
    #deal with changing the counties
    observeEvent(input$states_for_counties, {
        updateSelectInput(session, "county_to_highlight", choices = sort(unique(state_map()$NAME)))
    })  
    
    output$statePlot <- renderPlot({
        
        map_plot(state_map(), state_coronavirus(), input$type_counties, 
                 quo(NAME), trans = "identity")
        
        
    })
    output$stateTSPlot <- renderPlot({
        
        state_coronavirus_ts <- state_coronavirus() %>%
            as_tibble() %>%
            filter(type==input$type_counties) %>%
            group_by(date) %>%
            summarize(cases = sum(cases)) %>%
            ungroup() %>%
            arrange(date) %>%
            mutate(total_cases = cumsum(cases))
        
        total_plot_ts(state_coronavirus_ts, input$type_counties, 
                      title = paste0(input$states_for_counties," Over Time"))
        
        
    })
    
    output$countyTSPlot <- renderPlot({
        
        county_coronavirus_ts <- state_coronavirus() %>%
            filter(type==input$type_counties) %>%
            group_by(NAME, date) %>%
            summarize(cases = sum(cases)) %>%
            ungroup() %>%
            arrange(date) %>%
            group_by(NAME) %>%
            mutate(total_cases = cumsum(cases)) %>%
            ungroup()
        
        
        highlight_one_trajectory_plot(county_coronavirus_ts, 
                                      input$county_to_highlight, 
                                      quo(NAME),
                                      title_start = paste0(input$states_for_counties, " Counties"),
                                      nochina=FALSE , trans="identity")
    })
    
    output$distPlot <- renderPlot({

        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')

    })

})
