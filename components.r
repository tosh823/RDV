## components.r ##
## Return UI components for specific issue ##

strings <- list(
  timePeriodTitle = "Time period",
  timePeriodDesc = "Select time period",
  goldTitle = "Gold status",
  goldDesc = "Gilded",
  subredditsTitle = "Subreddits",
  subredditsDesc = "Select subreddits",
  keywordsTitle = "Keywords",
  keywordsDesc = "Type keywords"
) 

getCommentAnalysisComponents <- function(startTime, endTime) {
  return(
    tagList(
      fluidRow(
        box(
          title = strings$timePeriodTitle,
          dateRangeInput(
            "timeInput",
            label = h4(strings$timePeriodDesc),
            start = startTime,
            end = endTime,
            format = "dd/mm/yy",
            min = startTime, 
            max = endTime
          )
        ),
        box(
          title = strings$goldTitle,
          radioButtons(
            "isGilded",
            label = h4(strings$goldDesc),
            choices = list(
              "All" = 1, 
              "Yes" = 2, 
              "No" = 3
            ), 
            selected = 1
          )
        )
      ),
      
      fluidRow(
        box(
          title = strings$subredditsTitle,
          selectizeInput(
            'subredditsInput',
            label = h4(strings$subredditsDesc),
            choices = c(), 
            multiple = TRUE,
            options = list(
              create = TRUE, 
              maxItems = 10000, 
              placeholder = '/r/...'
            )
          )
        ),
        box(
          title = strings$keywordsTitle,
          selectizeInput(
            'keywordsInput',
            label = h4(strings$keywordsDesc),
            choices ="",
            multiple = TRUE,
            options = list(
              create = TRUE, 
              maxItems = 10000, 
              placeholder = 'Keyword'
            )
          )
        )
      ),
      
      fluidRow(  
        box(
          title = "Downvotes",
          sliderInput(
            "downs", 
            label = h4("Select a range of downvotes"), 
            min = 0, 
            max = 100, 
            value = c(0, 100)
          )
        ),
        box(
          title = "Upvotes",
          sliderInput(
            "ups", 
            label = h4("Select a range of upvotes"), 
            min = 0, 
            max = 100, 
            value = c(0, 100)
          )
        )
      ),
      actionButton(
        "launchButton", 
        label = "Release the Kraken!"
      )
    )
  )
}

getCommentAnalysisPlotUI <- function() {
  return(
    tagList(
      fluidRow(
        box(
          title = "Plot",
          width = 8,
          status = "primary", 
          solidHeader = TRUE,
          plotOutput(
            "graph", 
            height = 250
          )
        ),
        box(
          title = "Settings",
          status = "primary",
          solidHeader = TRUE,
          width = 4,
          selectInput(
            'plotSelect',
            label = h4("Plot type"),
            choices = list(
              "Bar chart" = 1, 
              "Line chart" = 2
            ),
            selected = 1
          ),
          checkboxInput(
            "separateSubreddits", 
            label = "Separate subreddits", 
            value = FALSE
          )
        )
      )
    )
  )
}

getUserAnalysisComponents <- function(startTime, endTime) {
  return(
    tagList(
      fluidRow(
        box(
          title = strings$timePeriodTitle,
          dateRangeInput(
            "timeInput",
            label = h4(strings$timePeriodDesc),
            start = startTime,
            end = endTime,
            format = "dd/mm/yy",
            min = startTime, 
            max = endTime
          )
        )
      ),
      actionButton(
        "launchButton", 
        label = "Release the Kraken!"
      )
    )
  )
}

getUserAnalysisPlotUI <- function() {
  return(
    tagList(
      fluidRow(
        box(
          title = "Plot",
          width = 8,
          status = "primary", 
          solidHeader = TRUE,
          plotOutput(
            "graph", 
            height = 250
          )
        ),
        box(
          title = "Settings",
          status = "primary",
          solidHeader = TRUE,
          width = 4
        )
      )
    )
  )
}

getSubredditAnalysisComponents <- function(startTime, endTime) {
  return(
    tagList(
      fluidRow(
        box(
          title = strings$timePeriodTitle,
          dateRangeInput(
            "timeInput",
            label = h4(strings$timePeriodDesc),
            start = startTime,
            end = endTime,
            format = "dd/mm/yy",
            min = startTime, 
            max = endTime
          )
        )
      ),
      actionButton(
        "launchButton", 
        label = "Release the Kraken!"
      )
    )
  )
}

getSubredditAnalysisPlotUI <- function() {
  return(
    tagList(
      fluidRow(
        box(
          title = "Plot",
          width = 8,
          status = "primary", 
          solidHeader = TRUE,
          plotOutput(
            "graph", 
            height = 250
          )
        ),
        box(
          title = "Settings",
          status = "primary",
          solidHeader = TRUE,
          width = 4
        )
      )
    )
  )
}

getSubredditRelationsComponents <- function(startTime, endTime) {
  return(
    tagList(
      fluidRow(
        box(
          title = strings$timePeriodTitle,
          dateRangeInput(
            "timeInput",
            label = h4(strings$timePeriodDesc),
            start = startTime,
            end = endTime,
            format = "dd/mm/yy",
            min = startTime, 
            max = endTime
          )
        )
      ),
      actionButton(
        "launchButton", 
        label = "Release the Kraken!"
      )
    )
  )
}

getSubredditRelationsPlotUI <- function() {
  return(
    tagList(
      fluidRow(
        box(
          title = "Plot",
          width = 8,
          status = "primary", 
          solidHeader = TRUE,
          plotOutput(
            "graph", 
            height = 250
          )
        ),
        box(
          title = "Settings",
          status = "primary",
          solidHeader = TRUE,
          width = 4
        )
      )
    )
  )
}

getFrequencyComponents <- function(startTime, endTime) {
  return(
    tagList(
      fluidRow(
        box(
          title = strings$timePeriodTitle,
          dateRangeInput(
            "timeInput",
            label = h4(strings$timePeriodDesc),
            start = startTime,
            end = endTime,
            format = "dd/mm/yy",
            min = startTime, 
            max = endTime
          )
        ),
        box(
          title = strings$goldTitle,
          radioButtons(
            "isGilded",
            label = h4(strings$goldDesc),
            choices = list(
              "All" = 1, 
              "Yes" = 2, 
              "No" = 3
            ), 
            selected = 1
          )
        )
      ),
      fluidRow(
        box(
          title = strings$subredditsTitle,
          selectizeInput(
            'subredditsInput',
            label = h4(strings$subredditsDesc),
            choices = c(), 
            multiple = TRUE,
            options = list(
              create = TRUE, 
              maxItems = 10000, 
              placeholder = '/r/...'
            )
          )
        ),
        box(
          title = strings$keywordsTitle,
          selectizeInput(
            'keywordsInput',
            label = h4(strings$keywordsDesc),
            choices ="",
            multiple = TRUE,
            options = list(
              create = TRUE, 
              maxItems = 10000, 
              placeholder = 'Keyword'
            )
          )
        )
      ),
      
      fluidRow(  
        box(
          title = "Downvotes",
          sliderInput(
            "downs", 
            label = h4("Select a range of downvotes"), 
            min = 0, 
            max = 100, 
            value = c(0, 100)
          )
        ),
        box(
          title = "Upvotes",
          sliderInput(
            "ups", 
            label = h4("Select a range of upvotes"), 
            min = 0, 
            max = 100, 
            value = c(0, 100)
          )
        )
      ),
      actionButton(
        "launchButton", 
        label = "Release the Kraken!"
      )
    )
  )
}

getFrequencyPlotUI <- function() {
  return(
    tagList(
      fluidRow(
        box(
          title = "Plot",
          width = 8,
          status = "primary", 
          solidHeader = TRUE,
          plotOutput(
            "graph", 
            height = 250
          )
        ),
        box(
          title = "Settings",
          status = "primary",
          solidHeader = TRUE,
          width = 4,
          sliderInput(
            "frequencyMin",
            label = h4("Minimum frequency:"),
            min = 1,  
            max = 50, 
            value = 15
          ),
          sliderInput(
            "numberOfWordsMax",
            label = h4("Maximum number of words:"),
            min = 1,  
            max = 100,
            value = 50
          )
        )
      )
    )
  )
}