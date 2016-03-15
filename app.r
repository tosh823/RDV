## app.R ##
library(shiny)
library(RMySQL)
library(ggplot2)
library(wordcloud)
library(networkD3)

source('./ui.r')
source('./dbQuery.r')
source('./processing.r')
source('./components.r')

# Des server details
# user="acp"
# password="acpdev16"
# dbname="acp_dev"
# host="46.101.153.165"
# port=3306

server <- function(input, output, session) {
  
  # Insert your user and password
  con <- dbConnect(
    MySQL(),
    user="acp",
    password="acpdev16",
    dbname="acp_dev",
    host="46.101.153.165",
    port=3306
  )
  
  # Getting start time of dataset
  minTimeQuery <- getMinValue(scheme$createTime)
  rs <- dbSendQuery(con, minTimeQuery)
  minTime <- fetch(rs, n=-1)
  startTime <- convertTime(minTime)
  dbClearResult(rs)
  
  # Getting end time of dataset
  maxTimeQuery <- getMaxValue(scheme$createTime)
  rs <- dbSendQuery(con, maxTimeQuery)
  maxTime <- fetch(rs, n=-1)
  endTime <- convertTime(maxTime)
  dbClearResult(rs)
  
  # Fetching all subreddits in this dataset
  subredditsQuery <- findUniqueValuesWithinTime(
    field = scheme$subreddit,
    timeFrom = minTime,
    timeBefore = maxTime
  )
  rs <- dbSendQuery(con, subredditsQuery)
  datasetSubreddits <- fetch(rs, n=-1)
  dbClearResult(rs)
  
  output$patternDescription <- renderText({
    switch(input$patternSelect,
      "1" = "Amount of comments pattern draws a bar or line chart of the amount of comments from chosen subreddits. The results can also be limited to those which include given keywords or authors.",
      "2" = "Subreddit relations pattern draws a node chart about how subreddits are connected. For example, if there are at least 50% shared commenters, an edge is plotted. The amount of shared commenters is compared to the mean of the two subreddits. The percentage of shared commenters can be adjusted below.",
      "3" = "Frequency of words pattern draws a word cloud of the most used words within chosen subreddits.",
      "Please select the desired type of data processing and define input parametres.
      The description of patter will appear here."
    )
  })
  
  observeEvent(input$patternSelect, {
    # Filtering unique subreddits
    # and updating the subreddits input
    updateSelectizeInput(session, "subredditsInput", choices = datasetSubreddits$subreddit)
  })
  
  output$inputComponents <- renderUI(
    switch(input$patternSelect,
      "1" = {
        # Comment analysis input components
        getCommentAnalysisComponents(startTime$time, endTime$time)
      },
      "2" = {
        # Subreddit relations input components
        getSubredditRelationsComponents(startTime$time, endTime$time)
      },
      "3" = {
        # Frequency of words input components
        getFrequencyComponents(startTime$time, endTime$time)
      },
      {
        # Default input components
      }
    )
  )
  
  output$plotUI <- renderUI({
    switch(input$patternSelect,
      "1" = {
        # Comment analysis plot UI
        getCommentAnalysisPlotUI()
      },
      "2" = {
        # Subreddit relations UI
        getSubredditRelationsPlotUI()
      },
      "3" = {
        # Frequency of words UI
        getFrequencyPlotUI()
      },
      {
        # Default UI
        getDefaultPlotUI()
      }
    )
  })
  
  output$queryInfoUI <- renderUI({
    switch(input$infoSelect,
      "2" = {
        # Show query
        textOutput("query_info")
      },
      "3" = {
        # Show query results
        dataTableOutput("query_results")
      },
      {
        # Default empty
      }
    )
  })
  
  observeEvent(input$menu, {
    switch(input$menu,
      "default" = {
        print("Default tab opened")
      },
      "conf" = {
        print("Configuration tab opened")
        
      },
      "plot" = {
        print("Plot tab opened")
        processConfiguration()
      },
      {
        print("Unknown tab opened")
      }
    )
  })
  
  # Launch Button onClick
  processConfiguration <- function() {
  #observeEvent(input$launchButton, {
    # The main thing is pattern
    pattern <- input$patternSelect
    switch(pattern,
      "1" = {
        # Comment analysis
        print("Starting comment analysis")
        # Taking input parameters
        periodStart <- input$timeInput[1]
        periodStartPOSIX <- as.numeric(as.POSIXct(periodStart, tz = "UTC"))
        periodEnd <- input$timeInput[2]
        periodEndPOSIX <- as.numeric(as.POSIXct(periodEnd, tz = "UTC"))
        gilded <- input$isGilded
        keywords <- input$keywordsInput
        authors <- input$authorsInput
        subreddits <- input$subredditsInput
        upVotesMin <- input$ups[1]
        upVotesMax <- input$ups[2]
        # Making query
        query <- commentAnalysis(
          gilded = as.numeric(gilded),
          upsMin = upVotesMin,
          upsMax = upVotesMax,
          timeFrom = periodStartPOSIX,
          timeBefore = periodEndPOSIX,
          subreddits = subreddits,
          authors = authors,
          keywords = keywords
        )
        print(query)
        res <- dbSendQuery(con, query)
        # What if not taking all the data at once?
        data <- data.frame()
        withProgress(
          message = 'Sending query...',
          value = 1, {
            while(!dbHasCompleted(res)){
              chunk <- dbFetch(res, n = 500)
              chunk <- convertTime(chunk)
              data <- rbind(data, chunk)
              setProgress(message = paste("Fetching", nrow(data), "rows..."))
            }
            setProgress(message = "Fetching completed.")
        })
        dbClearResult(res)
        
        # Output query info and results
        output$query_info <- renderText({
          query
        })
        output$query_results <- renderDataTable({
          data
        })
        
        makePlot <- function(){
          if (input$separateSubreddits == FALSE) {
            # All results
            mass <- createAmountFrame(data, "time")
            if (input$plotSelect == "1") {
              ggplot(data=mass, aes(x=time, y=freq, fill=time)) + 
                geom_bar(colour="black", width=.8, stat="identity") + 
                geom_label(aes(label = freq), size = 4) +
                guides(fill=FALSE) +
                xlab("Time") + ylab("Frequency") +
                ggtitle("Comment Analysis")
            }
            else if (input$plotSelect == "2") {
              ggplot(data=mass, aes(x=factor(time), y=freq, group = 1)) +  
                geom_line() + geom_point() +
                xlab("Time") + ylab("Frequency") +
                ggtitle("Comment Analysis")
            }
          }
          else {
            # Separating results by subreddits
            mass <- createAmountFrame(data, c("subreddit", "time"))
            if (input$plotSelect == "1") {
              ggplot(data=mass, aes(x=time, y=freq, fill=subreddit)) + 
                geom_bar(colour="black", width=.8, stat="identity") + 
                xlab("Time") + ylab("Frequency") +
                ggtitle("Comment Analysis by subreddits")
            }
            else if (input$plotSelect == "2") {
              ggplot(data=mass, aes(x=factor(time), y=freq, group=subreddit, colour=subreddit, shape=subreddit)) +  
                geom_line() + geom_point() +
                xlab("Time") + ylab("Frequency") +
                ggtitle("Comment Analysis")
            }
          }
        }
        
        savePlot <- function(file) {
          ggsave(file)
          p <- makePlot()
          print(p)
        }
        
        output$graph <- renderPlot({
          makePlot()
        })
      },
      "2" = {
        # Subreddits relations
        print("Starting subreddits relations analysis")
        
        # Taking input parameters
        periodStart <- input$timeInput[1]
        periodStartPOSIX <- as.numeric(as.POSIXct(periodStart, tz = "UTC"))
        periodEnd <- input$timeInput[2]
        periodEndPOSIX <- as.numeric(as.POSIXct(periodEnd, tz = "UTC"))
        gilded <- input$isGilded
        keywords <- input$keywordsInput
        subreddits <- input$subredditsInput
        upVotesMin <- input$ups[1]
        upVotesMax <- input$ups[2]
        relation <- input$percentage
        minSubreddit <- input$minSubredditSize
        
        #Making a query
        query <- subredditsRelations(
          gilded = as.numeric(gilded),
          upsMin = upVotesMin,
          upsMax = upVotesMax,
          timeFrom = periodStartPOSIX,
          timeBefore = periodEndPOSIX,
          subreddits = subreddits,
          keywords = keywords,
          percentage = relation,
          minSub = minSubreddit
        )

        res <- dbSendQuery(con, query)
        data <- data.frame()
        withProgress(
          message = 'Sending query...',
          value = 1, {
            while(!dbHasCompleted(res)){
              chunk <- dbFetch(res, n = 500)
              data <- rbind(data, chunk)
              setProgress(message = paste("Fetching", nrow(data), "rows..."))
            }
            setProgress(message = "Fetching completed.")
          })
        dbClearResult(res)
        
        # Output query info and results
        output$query_info <- renderText({
          query
        })
        output$query_results <- renderDataTable({
          data
        })
        
        networkData <- data.frame(data$subreddit_a, data$subreddit_b)
        
        makePlot <- function(){
          simpleNetwork(
            networkData, 
            fontSize = 20
          )
        }
        
        savePlot <- function(file) {
          saveNetwork(file)
          makePlot()
        }
        
        #plotting, if there is no data text is written
          output$network <- renderSimpleNetwork({
            validate(
              need(nrow(networkData)!= 0, "The query is empty so a plot is not drawn.")
            )
            makePlot()
          })
          
        
      },
      "3" = {
        # Frequency of words
        print("Starting frequence of words")
        # Taking input parametres
        periodStart <- input$timeInput[1]
        periodStartPOSIX <- as.numeric(as.POSIXct(periodStart, tz = "UTC"))
        periodEnd <- input$timeInput[2]
        periodEndPOSIX <- as.numeric(as.POSIXct(periodEnd, tz = "UTC"))
        gilded <- input$isGilded
        subreddits <- input$subredditsInput
        upVotesMin <- input$ups[1]
        upVotesMax <- input$ups[2]
        # Making a query
        query <- frequencyOfWords(
          gilded = as.numeric(gilded),
          upsMin = upVotesMin,
          upsMax = upVotesMax,
          timeFrom = periodStartPOSIX,
          timeBefore = periodEndPOSIX,
          subreddits = subreddits
        )
        print(query)
        res <- dbSendQuery(con, query)
        data <- data.frame()
        withProgress(
          message = 'Sending query...',
          value = 1, {
            while(!dbHasCompleted(res)){
              chunk <- dbFetch(res, n = 500)
              data <- rbind(data, chunk)
              setProgress(message = paste("Fetching", nrow(data), "rows..."))
            }
            setProgress(message = "Fetching completed.")
          })
        dbClearResult(res)
        
        # Output query info and results
        output$query_info <- renderText({
          query
        })
        output$query_results <- renderDataTable({
          data
        })
        
        corpus <- createCorpusWithProgress(data, scheme$comment)
        
        makePlot <- function(){
          wordcloud(
            corpus, 
            scale = c(3.5, 0.5),
            min.freq = input$frequencyMin,
            max.words = input$numberOfWordsMax, 
            random.order = FALSE,
            random.color = FALSE,
            colors = brewer.pal(8, "Dark2")
          )
        }
        
        savePlot <- function(file) {
          png(file)
          makePlot()
        }
        
        output$graph <- renderPlot({
          makePlot()
        })
        
      },
      {
        # Default
      }
    )
    
    # Creating saving behaviour
    
    if(input$patternSelect != 2){
      output$downloadPlot <- downloadHandler(
        filename = function() { 
          "output.png" 
        },
        content = function(file) {
          savePlot(file)
          dev.off()
        }
      )
    } else {
      output$downloadPlot <- downloadHandler(
        filename = function() { 
          "output.html" 
        },
        content = function(file) {
          savePlot(file)
          dev.off()
        }
      )
    }
    
  }
  
  # Cleanup after closing session
  session$onSessionEnded(function() {
    print("Session closed...")
    dbDisconnect(con)
  })
}

shinyApp(ui, server)