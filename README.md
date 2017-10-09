# Ngram AdWords Analysis
### A Shiny app built for analyzing the Search Terms report from AdWords.


To run locally, clone the repo.
```bash
git clone https://github.com/beigebrucewayne/NgramShinyApp.git
```

Then, make sure you have R installed. The easiest way, if you have a Mac, is to use homebrew. Alternatively, you can alwasy download from [CRAN](https://cran.r-project.org/).
```bash
brew tap homebrew/science
brew install Caskroom/cask/xquartz
brew install r
```

Finally, start R in the project directory and invoke the Shiny library.
```r
library(shiny)
shiny::runApp()
```
