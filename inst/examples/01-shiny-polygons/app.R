library(shiny)
library(leaflet)

ui <- fluidPage(

  titlePanel("TargomoR Test"),

  sidebarLayout(

    sidebarPanel(
      selectInput("transport", "Mode of Transport",
                  choices = c("walk", "bike", "car", "transit"), selected = "car"),
      sliderInput("stroke", "Stroke Width",
                  min = 5, max = 30, value = 10, step = 5)
    ),
    mainPanel(
      leafletOutput("map")
    )
  )
)

server <- function(input, output, session) {

  basemap <- leaflet() %>% addProviderTiles("CartoDB.Positron")

  output$map <- renderLeaflet({
    map <- basemap %>%
      addTargomoPolygons(transport = input$transport, stroke = input$stroke)
    return(map)
  })

}

shinyApp(ui, server)
