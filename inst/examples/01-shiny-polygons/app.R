library(shiny)
library(leaflet)

ui <- fluidPage(

  titlePanel("TargomoR Test"),

  sidebarLayout(

    sidebarPanel(
      selectInput("transport", "Mode of Transport",
                  choices = c("Walking" = "walk",
                              "Cycling" = "bike",
                              "Car" = "car",
                              "Public Transport" = "transit"),
                  selected = "car"),
      sliderInput("stroke", "Stroke Width",
                  min = 5, max = 30, value = 10, step = 5),
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
      addTargomoPolygons(options = targomoOptions(transport = input$transport,
                                                  stroke = input$stroke,
                                                  invert = input$invert))
    return(map)
  })

}

shinyApp(ui, server)
