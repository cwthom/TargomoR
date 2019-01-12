library(shiny)
library(leaflet)

ui <- fluidPage(

  titlePanel("TargomoR Test"),

  sidebarLayout(

    sidebarPanel(
      selectInput("transport", "Mode of Transport",
                  choices = c("walk", "car"), selected = "car")
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
      addTargomoPolygons(transport = input$transport)
    return(map)
  })

}

shinyApp(ui, server)
