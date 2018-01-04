library(shiny)
library(tidytext)
library(shinythemes)
library(tidyverse)
library(DT)
library(wordcloud)

ui <- fluidPage(theme = shinytheme("simplex"),

  titlePanel("AdWords N-gram Analysis"),
  # custom css
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap.css")
  ),
  # Sidebar layout with input and output definitions
  sidebarLayout(
    # Sidebar panel for inputs
    sidebarPanel(
      h4('Before you upload!'),
      p('Read the', a(href='https://github.com/beigebrucewayne/NgramShinyApp/blob/master/README.md', 'data cleaning'), 'section.'),
      hr(),
      # Input -> Select a file
      fileInput("file1", "Choose CSV File",
                multiple = TRUE,
                accept = c("text/csv",
                         "text/comma-separated-values,text/plain",
                         ".csv")),
      hr(),
      h4('N-gram Data Table'),
      p('This will change the number of grams the data table shows.'),
      br(),
      sliderInput('ngramCount', '# of Grams', min = 1, max = 6, value = 1),
      hr(),
      h4('N-gram Wordcloud'),
      p('This will change the max words shown for the word cloud.'),
      br(),
      sliderInput('cloudCount', '# of Words', min = 50, max = 400, value = 100),
      hr(),
      plotOutput("wordcloud"),
      hr(),
      p('Having trouble?'),
      p('email: kade.killary@xmedia.com'),
      p(a(href='https://github.com/beigebrucewayne/NgramShinyApp/issues', 'file an issue'))
    ),
    # Main panel for displaying outputs
    mainPanel(
      img(src='https://i.imgur.com/kB1qKI0.png', align = 'center'),
      br(),br(),
      h3('What\'s an N-gram?'),
      p('An n-gram is a contiguous sequence of n items from a given sequence of text or speech. You can read more', a(href='http://text-analytics101.rxnlp.com/2014/11/what-are-n-grams.html', 'here'), 'and', a(href='https://searchengineland.com/brainlabs-script-find-best-worst-search-queries-using-n-grams-228379', 'here.')),
      hr(),
      h3('Why it matters:'),
      p('This tool helps you mine your Search Terms report at a deeper level. Typically, you pull the report and aggregate terms on a phrase level. This misses a ton of opportunities. N-gram analysis helps to uncover the common phrases, and pairings, that are triggering your keywords. Ideally, you use this to find new negative and positive keywords.'),
      br(), br(),
      # Output -> Data file
      DT::dataTableOutput("contents")
    )
  )
)

server <- function(input, output) {

  output$wordcloud  <- renderPlot({
    req(input$file1)
    df  <- read_csv(input$file1$datapath)
    names(df) %<>%
      tolower() %>%
      stringr::str_replace_all(" ","")
    df %>%
      dplyr::select(searchterm) %>%
      tidytext::unnest_tokens(ngram, searchterm, token="ngrams", n=input$ngramCount) %>%
      count(ngram) %>%
      with(wordcloud(ngram, n, max.words=input$cloudCount, rot.per=.1, random.color=FALSE, random.order=TRUE, colors=c("#000000", "#FF1A1A")))
  })

  output$contents <- DT::renderDataTable({
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, head of that data file by default,
    # or all rows if selected, will be shown.
    req(input$file1)
    df  <- read_csv(input$file1$datapath)
    names(df) %<>%
      tolower() %>%
      stringr::str_replace_all(" ", "")
    DT::datatable(head(df %>%
          dplyr::select(searchterm, impr., clicks, ctr, cost, conversions) %>%
          tidytext::unnest_tokens(ngram, searchterm, token="ngrams", n=input$ngramCount) %>%
          dplyr::group_by(ngram) %>%
          dplyr::summarize(
            sum.impr = round(sum(impr.), 2),
            avg.impr = round(mean(impr.), 2),
            sum.clicks = round(sum(clicks), 2),
            avg.clicks = round(mean(clicks), 2),
            avg.ctr = round(avg.clicks / avg.impr, 2),
            avg.cpc = round(sum(cost) / sum(clicks), 2),
            sum.convr = round(sum(conversions), 2),
            avg.costperconv = round(sum.convr / sum(cost), 2)
          ) %>%
          dplyr::arrange(desc(sum.clicks)), 100),
        class = "stripe hover compact order-column",
        extensions = 'Buttons',
        caption = 'You can sort and filter by column and export to a variety of options.',
        options = list(
          dom = 'Bfrtip',
          buttons = c('copy', 'csv', 'excel', 'pdf', 'print'),
          pageLength = 50
          ),
        filter = 'top'
        )
    })
}


shinyApp(ui, server)
