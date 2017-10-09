library(shiny)
library(tidytext)
library(shinythemes)
library(tidyverse)

ui <- fluidPage(theme = shinytheme("darkly"),

  titlePanel("AdWords N-gram Analysis"),
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
      # Horizontal line
      hr(),
      # Input -> Select number of rows to display
      radioButtons("disp", "Display",
                   choices = c(Head = "head",
                               Top50 = "top50"),
                   selected = "head"),
      hr(),
      sliderInput('ngramCount', '# of Grams', min = 1, max = 6, value = 1)
    ),
    # Main panel for displaying outputs
    mainPanel(
      img(src='https://i.imgur.com/kB1qKI0.png', align = 'center'),
      br(),br(),
      h3('What\'s an N-gram?'),
      p('An n-gram is a contiguous sequence of n items from a given sequence of text or speech', 
        a(href='http://text-analytics101.rxnlp.com/2014/11/what-are-n-grams.html', ' - a more detailed explanation.'),
        a(href='https://searchengineland.com/brainlabs-script-find-best-worst-search-queries-using-n-grams-228379', 'Even more information'),
        p('on the power of N-grams for AdWords.')),
      hr(),
      h3('Why it matters:'),
      p('This tool helps you mine your Search Terms report at a deeper level. Typically, you pull the report and aggregate terms on a phrase level. This misses a ton of opportunities. N-gram analysis helps to uncover the common phrases, and pairings, that are triggering your keywords. Ideally, you use this to find new negative and positive keywords.'),
      br(), br(),
      # Output -> Data file
      tableOutput("contents")
    )
  )
)

server <- function(input, output) {

  output$contents <- renderTable({
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, head of that data file by default,
    # or all rows if selected, will be shown.
    req(input$file1)
    df <- read.csv(input$file1$datapath, header = input$header, sep = input$sep)
    if (input$disp == "head") {
      head(df %>%
        dplyr::select(search.term, impr, clicks, ctr, convr, cpc) %>%
        tidytext::unnest_tokens(ngram, search.term, token="ngrams", n=input$ngramCount) %>%
        dplyr::group_by(ngram) %>%
        dplyr::summarize(
          sum.impr = sum(impr),
          avg.impr = mean(impr),
          sum.clicks = sum(clicks),
          avg.clicks = mean(clicks),
          avg.ctr = avg.clicks / avg.impr,
          sum.convr = sum(convr),
          avg.convr = mean(convr),
          avg.cpc = mean(cpc)
        ) %>%
        dplyr::arrange(desc(sum.clicks))
      )
    } else {
      head(df %>%
        dplyr::select(search.term, impr, clicks, ctr, convr, cpc) %>%
        tidytext::unnest_tokens(ngram, search.term, token="ngrams", n=input$ngramCount) %>%
        dplyr::group_by(ngram) %>%
        dplyr::summarize(
          sum.impr = sum(impr),
          avg.impr = mean(impr),
          sum.clicks = sum(clicks),
          avg.clicks = mean(clicks),
          avg.ctr = avg.clicks / avg.impr,
          sum.convr = sum(convr),
          avg.convr = mean(convr),
          avg.cpc = mean(cpc)
        ) %>%
        dplyr::arrange(desc(sum.clicks)), 50)
    }
  })
}

shinyApp(ui, server)
