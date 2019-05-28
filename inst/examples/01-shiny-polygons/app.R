library(shiny)
library(leaflet)
library(TargomoR)

ui <- fluidPage(

  titlePanel("TargomoR Test"),

  sidebarLayout(

    sidebarPanel(
      selectInput("transport", "Mode of Transport",
                  choices = c("Walking" = "walk",
                              "Cycling" = "bike",
                              "Car" = "car",
                              "Public Transport" = "transit"),
                  selected = "bike"),
      sliderInput("stroke", "Stroke Width",
                  min = 1, max = 20, value = 10, step = 1),
      checkboxInput("invert", "Invert Polygons?")

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
      addMarkers(lat = 55.9, lng = -3.1) %>%
      addTargomoPolygons(lat = 55.9, lng = -3.1,
                         options = targomoOptions(travelType = input$transport,
                                                  strokeWidth = input$stroke,
                                                  inverse = input$invert)
      )
    return(map)
  })

}

shinyApp(ui, server)
