# Nisha Patel
# Code File to Create R Shiny App
# App: Hourly Temperature Forecast (Powered by Meteomatics)
# Find helper functions in "helpers.R"


#----------- Load helper functions & load packages ---------------------#
source("helpers.R")
packagesList <- c("tidyverse", "lubridate", "stringr","jsonlite", 
                  "usa", "modelr", "leaflet", "shiny" , 'httr2', 'data.table', 
                  'lubridate', 'stringr', 'jsonlite', 
                   'sets', 'tidyr', 'utils', 'zipcodeR', 'rjson', 'conflicted')

lapply(packagesList, installPackages)
conflict_prefer("%>%", "dplyr")

#---------------------------------------------------------#

ui <- fluidPage(
  
  # CSS related code to style app page
  tags$head(
    tags$style(HTML("
                    @import url('//fonts.googleapis.com/css?family=Lobster|Cabin:400,700');
                    ",
                    
                    "#sidebar {
                      background-color: #3877D6;
                      font-family: 'Arial Black';
                      font-weight:200;
                     
                    }"
                    
                    ))
    ),
  
  
  theme = "bootstrapDarkTheme.css",
  titlePanel( h1(" Hourly Weather Forecast App", 
                 style = "font-family: 'lobster', cursive; font-weight: 400; 
                         color: #3877D6;")),
  
  sidebarLayout(
    
    sidebarPanel(id = "sidebar",
                 
      fluidRow(
        
        # Zip input, forecast, plot title input, and download plot buttons
        column(6, numericInput(inputId = 'zip', label = "Enter Your Zipcode (5 digits only)", value = 0
                               ),
               actionButton(inputId = 'forecast', label= 'Forecast')),
        
        column(6, textInput(inputId = "plot_title", label = "Enter plot name to download"),
               
               downloadButton(outputId = "download_plot", label = "Download Plot"))
        
      ) , # end fluidRow
      
      # Note: Attribution to Dark Sky
      fluidRow(tags$a(href = "https://www.meteomatics.com/en/weather-app/", "Powered by Meteomatics Weather API"))
      
    ), # end sidebar panel
    
    mainPanel(
      
      # First tab is forecast plot, second tab has leaflet map of location 
      tabsetPanel(type = "tabs",
                  
                  tabPanel("Forecast Plot", plotOutput(outputId = "location")),
    
                  tabPanel("Map View",  leafletOutput(outputId = "map"))
       )
    
      
    ) # end main panel
    
    
    
  ) # end sidebar layout
  

  
) # end UI


server <- function(input, output){
  
  # After zip input, if user clicks forecast, then hourly temp plot will be generated
  out_plot <- eventReactive(input$forecast, { 
    
    location_plot_output(input$zip)
     
  })
  
  # After zip input, if user clicks forecast, then leaflet map of input location will be generated
  out_leaflet <- eventReactive(input$forecast, {
    
    location = geocode_zip(zip_code = input$zip)
    
    
    reverse_zipcode_data = reverse_zipcode(location$zipcode)
    user_city_state = str_c(reverse_zipcode_data$major_city[[1]], reverse_zipcode_data$state[[1]], sep = ",")
    
    leaflet() %>% addTiles() %>% 
      addMarkers(location$lng, location$lat, popup = str_c(location$lat, location$lng, sep=","),label = user_city_state)
    
  })
  
  # Show plot 
  output$map <- renderLeaflet(out_leaflet())
  
  # Show leaflet
  output$location <- renderPlot(out_plot())
 
  
  # Enable downloading and saving of plot
  output$download_plot <- downloadHandler(
    
    filename = function() {
      
      # Let user choose title for saving plot based on input
      str_c(input$plot_title, ".jpg", sep = "")
      
      },
    
    content = function(file) {
      
      ggsave(file, width = 10, height = 6, units = "in")
      
      }
    
  )
    
  
 
} # end server


shinyApp(ui = ui, server = server)


