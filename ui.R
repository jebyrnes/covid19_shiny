#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(coronavirus)
library(dplyr)
library(rnaturalearth)
library(rnaturalearthhires)

coronavirus <- update_coronavirus_raw(returnclass = "data.frame")
us_coronavirus <- coronavirus %>% filter(Country.Region=="United States of America")
us_map <- ne_states(country = "United States of America", returnclass = "sf")
#ma_map <- sf::st_as_sf(counties(state="Massachusetts", cb = TRUE)) 
ma_map <- readRDS("./counties/Massachusetts.rds")
    
# Define UI for application that draws a histogram
shinyUI(fluidPage(
    theme = shinythemes::shinytheme("yeti"),

    # Application title
    titlePanel("Distribution and Time Series of Covid-19 Cases"),
    
    tabsetPanel(
        
        # Whole World ----
        tabPanel("Whole World", fluid = TRUE,

                 # Sidebar with a slider input for number of bins
                 sidebarLayout(sidebarPanel(
                     
                     selectInput(
                     inputId = "countries",
                     label = "Country to Highlight:",
                     choices = sort(unique(coronavirus$Country.Region)),
                     selected = "Italy"
                 ),
                 
                 selectInput(
                     inputId = "type",
                     label = "Type of Cases:",
                     choices = sort(unique(coronavirus$type)),
                     selected = "confirmed"
                 )
                 ),
                 
                 # Show a plot of the generated distribution
                 mainPanel(plotOutput("worldPlot"),
                           plotOutput("worldTSPlot"),
                           plotOutput("countryTSPlot")
                 ))
        ),
        
        # United States ----
        tabPanel("United States", fluid = TRUE,
                 
                 # Sidebar with a slider input for number of bins
                 sidebarLayout(sidebarPanel(
                     
                     selectInput(
                         inputId = "states",
                         label = "State to Highlight:",
                         choices = sort(unique(us_map$name)),
                         selected = "Massachusetts"
                     ),
                     
                     selectInput(
                         inputId = "typeus",
                         label = "Type of Cases:",
                         choices = sort(unique(coronavirus$type)),
                         selected = "confirmed"
                     )
                 ),
                 
                 # Show a plot of the generated distribution
                 mainPanel(plotOutput("usPlot"),
                           plotOutput("usTSPlot"),
                           plotOutput("usStateTSPlot")
                 ))
                ),
        
        # US State Counties ----
        tabPanel("US State Counties", fluid = TRUE,
                 
                 # Sidebar with a slider input for number of bins
                 sidebarLayout(sidebarPanel(
                     
                 selectInput(
                     inputId = "states_for_counties",
                     label = "State:",
                     choices = sort(unique(us_map$name)),
                     selected = "Massachusetts"
                 ),
                 
                 selectInput(
                     inputId = "county_to_highlight",
                     label = "County to Highlight:",
                     choices = sort(unique(ma_map$NAME)),
                     selected = "Middlesex"
                 ),
                 
                 selectInput(
                     inputId = "type_counties",
                     label = "Type of Cases:",
                     choices = sort(unique(coronavirus$type)),
                     selected = "confirmed"
                 )
        ),
                 
                 # Show a plot of the generated distribution
                 mainPanel(plotOutput("statePlot"),
                           plotOutput("stateTSPlot"),
                           plotOutput("countyTSPlot")
                 ))
        ),
        
        # About ----
        tabPanel("About", fluid = TRUE,
                 
                HTML('<br><br>A number of weeks ago, as  <a href="https://www.cdc.gov/coronavirus/2019-ncov/index.html">Covid-19</a> began to arise, I was teaching <a href="http://biol355.github.io">my data science class</a> and seeking to make the work relevant. I noticed that a wonderful data scientist, <A href="https://twitter.com/Rami_Krispin">Rami Krispin</a> was making some of the data from JHU available via a <a href="https://ramikrispin.github.io/coronavirus/">coronavirus package for R</a>.
                     <br><br> This was just the thing I was looking for to make the work relevant for my students. So, I made some exercises. Then, as things progressed, I found myself digging more into the data myself, particularly as I taught geospatial exploration. I got involved enough that I created my own branch of the package to pull data directly and provide geospatial datasets as part of the package. These will hopefully be merged in soon.
                     <br><Br>I have also found it comforting, in an odd way, to work with the data. To give myself a feel like a measure of control. That... and I am teaching shiny in a few weeks, and am pretty new to it.
                     <br><br>So, in answer to my own desire to explore the data, and questions from friends, I have created this site.
                     <br><br>It uses my branch of the package, and pulls the data, fresh, every time you reload the package. The raw data pulled and arranged by the <a href="https://coronavirus.jhu.edu/">Johns Hopkins University Center for Systems Science and Engineering (JHU CCSE)</a> that is posted in <a href="https://github.com/CSSEGISandData/COVID-19">this repository</a>. 
                     <br><br><font color = "red">A warning</font>: it might not always be 100% correct. There are issues and funny things in the data, and it is being updated in realtime.
                     <br><br>If you find odd things, feel free to file an <a href="https://github.com/jebyrnes/covid19_shiny/issues">issue with me</a>, or, if it is something you notice in a data, file an issue with JHU directly <A href="https://github.com/CSSEGISandData/COVID-19/issues">here</a>.
                     <br><br>The code for this Shiny app can be found <a href="https://github.com/jebyrnes/covid19_shiny">here</a>. Spatial data are from the rnaturalearth and tigris R libraries. Feel free to contact me if you want to contribute, fork and pull, or make suggestions.
                     <br><br>Hope you find this useful!<br><br>-<a href="http://byrneslab.net">Jarrett Byrnes</a>, <a href="http://twitter.com/jebyrnes">@jebyrnes</a>
                     ')
        )
        
    )
))
