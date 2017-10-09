library(shiny)
library(shinythemes)

# Define UI for data upload app
ui <- fluidPage(theme = shinytheme("darkly"),

  # App title
  titlePanel("AdWords Ngram Analysis"),
  # Sidebar layout with input and output definitions
  sidebarLayout(
    # Sidebar panel for inputs
    sidebarPanel(
      # Input -> Select a file
      fileInput("file1", "Choose CSV File",
                multiple = TRUE,
                accept = c("text/csv",
                         "text/comma-separated-values,text/plain",
                         ".csv")),
      # Horizontal line
      hr(),
      # Input -> Checkbox if file has header
      checkboxInput("header", "Header", TRUE),
      # Input -> Select separator
      radioButtons("sep", "Separator",
                   choices = c(Comma = ",",
                               Semicolon = ";",
                               Tab = "\t"),
                   selected = ","),
      # Input -> Select quotes
      radioButtons("quote", "Quote",
                   choices = c(None = "",
                               "Double Quote" = '"',
                               "Single Quote" = "'"),
                   selected = '"'),
      # Horizontal line
      hr(),
      # Input -> Select number of rows to display
      radioButtons("disp", "Display",
                   choices = c(Head = "head",
                               Top50 = "top50"),
                   selected = "head")
    ),
    # Main panel for displaying outputs
    mainPanel(
      img(src='https://i.imgur.com/kB1qKI0.png', align = 'center'),
      br(),br(),
      p('Explain how to pull data, clean data, then interpret results'),
      # Output -> Data file
      tableOutput("contents")
    )
  )
)

# Define server logic to read selected file
server <- function(input, output) {

  output$contents <- renderTable({
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, head of that data file by default,
    # or all rows if selected, will be shown.
    req(input$file1)
    df <- read.csv(input$file1$datapath,
             header = input$header,
             sep = input$sep,
             quote = input$quote)
    if(input$disp == "head") {
      return(head(df))
    }
    else {
      return(head(df, 50))
    }
  })
}

shinyApp(ui, server)
