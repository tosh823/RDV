## dbQuery.r ##
## Operations with data ##

tableName <- "rawdata"
scheme <- list(
  comment = "body",
  gold = "gilded",
  score = "score",
  upVotes = "ups",
  downVotes = "downs",
  author = "author",
  subreddit = "subreddit",
  createTime = "created_utc"
)

commentAnalysis <- function(gilded = NULL, scoreMin = NULL, 
                            scoreMax = NULL, upsMin = NULL, 
                            upsMax = NULL, downsMin = NULL, 
                            downsMax = NULL, timeFrom = NULL,
                            timeBefore = NULL, keywords = NULL,
                            subreddits = NULL) {
  base <- c("SELECT id, author, subreddit, created_utc FROM ", tableName, " WHERE ")
  # Gold status condition
  if (!is.null(gilded) & gilded == 3) {
    base <- c(base, getValueEqual(scheme$gold, 0), " AND ")
  }
  else if (!is.null(gilded) & gilded == 2) {
    base <- c(base, getValueEqual(scheme$gold, 1), " AND ")
  }
  
  # Minimal score condition
  if (!is.null(scoreMin)) {
    base <- c(base, getValueMore(scheme$score, scoreMin), " AND ")
  }
  
  # Maximum score condition
  if (!is.null(scoreMax)) {
    base <- c(base, getValueLess(scheme$score, scoreMax), " AND ")
  }
  
  # Minimal upvotes condition
  if (!is.null(upsMin)) {
    base <- c(base, getValueMore(scheme$upVotes, upsMin), " AND ")
  }
  
  # Maximum upvotes condition
  if (!is.null(upsMax)) {
    base <- c(base, getValueLess(scheme$upVotes, upsMax), " AND ")
  }
  
  # Minimal downvotes condition
  if (!is.null(downsMin)) {
    base <- c(base, getValueMore(scheme$downVotes, downsMin), " AND ")
  }
  
  # Maximum downvotes condition
  if (!is.null(downsMax)) {
    base <- c(base, getValueLess(scheme$downVotes, downsMax), " AND ")
  }
  
  # Starting time condition
  if (!is.null(timeFrom)) {
    base <- c(base, getValueMore(scheme$createTime, timeFrom), " AND ")
  }
  
  # Ending time condition
  if (!is.null(timeBefore)) {
    base <- c(base, getValueLess(scheme$createTime, timeBefore), " AND ")
  }
  
  # Subreddits condition
  if (!is.null(subreddits)) {
    base <- c(base, getValueIn(scheme$subreddit, subreddits), " AND ")
  }
  
  # Keywords condition
  if (!is.null(keywords)) {
    base <- c(base, searchValue(scheme$comment, keywords), ";")
  }
  else {
    # Removing the last element in query (" AND ")
    # And putting the end to it
    base <- base[-length(base)]
    base <- c(base, ";")
  }
  
  query <- paste(base, sep = "", collapse = "")
  return(query)
}

subredditsAnalysis <- function() {
  query <- "SELECT b.subreddit AS subreddit_a, b.authors AS authors_in_sub_a, a.subreddit AS subreddit_b, FLOOR(100*COUNT(*)/b.authors) AS percent, COUNT(*)
FROM
  ((SELECT DISTINCT (author), subreddit FROM rawdata ORDER BY subreddit) AS a)
  JOIN 
  ((SELECT t1.author AS author, t1.subreddit AS subreddit, t2.authors AS authors
  FROM (SELECT DISTINCT author, subreddit FROM rawdata ) AS t1
  JOIN (SELECT subreddit, count(distinct author) AS authors FROM rawdata GROUP BY subreddit) AS t2
  WHERE t1.subreddit=t2.subreddit
  GROUP BY subreddit, author
  ) AS b /*b is a table which includes every distinct author in every subreddits and also the amount of distinct authors in every subreddit*/)
  ON a.author=b.author
  WHERE a.subreddit!=b.subreddit 
  GROUP BY 1,3;"
  return(query)
}

frequencyOfWords <- function() {
  base <- c("SELECT id, body FROM ", tableName, ";")
  query <- paste(base, sep = "", collapse = "")
  return(query)
}

getValueMore <- function(value, minValue) {
  base <- c(value, ">=", minValue)
  query <- paste(base, sep = "", collapse = "")
  return(query)
}

getValueEqual <- function(value, equalValue) {
  base <- c(value, "=", equalValue)
  query <- paste(base, sep = "", collapse = "")
  return(query)
}

getValueLess <- function(value, maxValue) {
  base <- c(value, "<=", maxValue)
  query <- paste(base, sep = "", collapse = "")
  return(query)
}

getValueIn <- function(value, list) {
  base <- c(value, " IN (", paste("'", list, "'", sep = "", collapse = ", "), ")")
  query <- paste(base, sep = "", collapse = "")
  return(query)
}

searchValue <- function(value, keywords) {
  # Search among keywords:
  # 1 option: WHERE body REGEXP 'key1|key2|key3'
  # 2 option WHERE body LIKE '%key1%' OR body LIKE '%key2%'...
  # TODO: Find what better
  keys <- paste(keywords, collapse = "|")
  base <- c(value, " REGEXP '", keys, "'")
  query <- paste(base, sep = "", collapse = "")
  return(query)
}

findUniqueValues <- function(field) {
  base <- c("SELECT DISTINCT ", field, " FROM ", tableName, " ORDER BY ", field, ";")
  query <- paste(base, sep = "", collapse = "")
  return(query)
}
