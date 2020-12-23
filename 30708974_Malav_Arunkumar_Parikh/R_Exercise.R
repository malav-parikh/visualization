#load libraries
library(ggplot2)
library(shiny)
library(leaflet)
library(htmltools)
library(dplyr)

#load datasets
FirstDataset = read.csv("Pedestrian_Counting_System_-_Sensor_Locations (Exercise 2).csv")
SecondDataset = read.csv("Pedestrian_Counting_System_2019 (Exercise 2).csv")

#data cleaning
#removing naming conflicts in both dataset
FirstDataset[FirstDataset=="Melbourne Central-Elizabeth St (East)Melbourne Central-Elizabeth St (East)"] <- "Melbourne Central-Elizabeth St (East)"
FirstDataset[FirstDataset=="RMIT Building 14"] <- "Swanston St - RMIT Building 14"
FirstDataset[FirstDataset=="Building 80 RMIT"] <- "Swanston St - RMIT Building 80"
SecondDataset[SecondDataset=="Pelham St (S)"] <- "Pelham St (South)"
SecondDataset[SecondDataset=="Lincoln-Swanston(West)"] <- "Lincoln-Swanston (West)"
SecondDataset[SecondDataset=="Flinders La - Swanston St (West) Temp"] <- "Flinders La-Swanston St (West)"
SecondDataset[SecondDataset=="Flinders la - Swanston St (West) Temp"] <- "Flinders La-Swanston St (West)"
SecondDataset[SecondDataset=="Collins St (North)"] <- "Collins Street (North)"

#changing column name to be able to join
colnames(SecondDataset)[colnames(SecondDataset) == "Sensor_Name"] = "sensor_name"

#combining datasets
CombinedDataset = inner_join(FirstDataset, SecondDataset, by = "sensor_name")

#wrangling data for first question
datasetQ1 = CombinedDataset %>% group_by(sensor_name,latitude,longitude) %>% summarise(avg_counts = mean(Hourly_Counts))
#removing nulls
datasetQ1 = filter(datasetQ1, avg_counts >= 0)
#sort dataset by names of sensor
datasetQ1 = datasetQ1[order(datasetQ1$sensor_name),]
#providing color function to be used to add color to markers
colorFunction = colorNumeric("Red", datasetQ1$avg_counts)

#wrangling data for question 2
datasetQ2 = CombinedDataset %>% group_by(sensor_name, latitude, longitude, Day, Time) %>% summarise(avg_counts = mean(Hourly_Counts))
#removing nulls
datasetQ2 = filter(datasetQ2, avg_counts >= 0)
#sort datasetQ2 by name,day,Time
datasetQ2$Day <- factor(datasetQ2$Day, levels= c("Monday", 
                                         "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday","Sunday"))

datasetQ2 = datasetQ2[order(datasetQ2$sensor_name,datasetQ2$Day,datasetQ2$Time),]


#creating Shiny UI page
ui= fluidPage(
  column(12,offset = 3, titlePanel("Pedestrian Traffic across Melboune")),
  
  flowLayout(
    selectInput(inputId = "sensor_input", label = "select a sensor:",choices = datasetQ1$sensor_name, selected = "")
  ),
  
  fluidRow(
    column(width = 6, plotOutput("plot", width = "100%", height = 400)),
    column(width = 6, leafletOutput("map", width = "100%", height = 375))
  )
)



#Shiny server side
server = shinyServer(function(input,output,session){
  
  output$map <- renderLeaflet({
    leaflet() %>% addTiles() %>%
      addCircleMarkers( 
        data = datasetQ1,
        stroke = TRUE, 
        fillOpacity = 0.65,
        color = ~colorFunction(avg_counts),
        radius = ~avg_counts/200,
        label = ~htmlEscape(sensor_name)
      ) %>% addProviderTiles("Stamen.Terrain")
    
    })
  
    observeEvent(input$map_marker_click,{
      mapClick = input$map_marker_click
      datasetQ2  = filter(datasetQ2, latitude == mapClick$lat, longitude == mapClick$lng)
      updateSelectInput(session, inputId = "sensor_input", selected = datasetQ2$sensor_name)
      output$plot = renderPlot({
        datasetQ2 = filter(datasetQ2, sensor_name == input$sensor_input)
        mygraph = ggplot(datasetQ2, aes(Time, avg_counts)) +
          geom_line() +
          facet_wrap(~Day)
        mygraph
      })
    })
    
    
    observeEvent(input$sensor_input,{
    output$plot = renderPlot({
      datasetQ2 = filter(datasetQ2, sensor_name == input$sensor_input)
      mygraph = ggplot(datasetQ2, aes(Time, avg_counts)) +
        geom_line() +
        facet_wrap(~Day)
      mygraph
      })
    })
    
})
  
shinyApp(ui,server)

