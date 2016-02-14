SELECT final.subreddit_a, final.subreddit_b FROM (
SELECT b.subreddit AS subreddit_a, b.authors AS authors_in_sub_a, a.subreddit AS subreddit_b, FLOOR(100*COUNT(*)/b.authors) AS percent, COUNT(*)
FROM
((SELECT DISTINCT (author), subreddit FROM rawdata WHERE author!='[deleted]' AND subreddit IN ('politics', 'reddit.com') ORDER BY subreddit) AS a)
JOIN 
((SELECT t1.author AS author, t1.subreddit AS subreddit, t2.authors AS authors
FROM (SELECT DISTINCT author, subreddit FROM rawdata WHERE author!='[deleted]' AND subreddit IN ('politics', 'reddit.com')) AS t1 /* deleted authors are not included*/
JOIN (SELECT subreddit, count(distinct author) AS authors FROM rawdata WHERE author!='[deleted]' AND subreddit IN ('politics', 'reddit.com') GROUP BY subreddit) AS t2
WHERE t1.subreddit=t2.subreddit
GROUP BY subreddit, author
) AS b /*b is a table which includes every distinct author in every subreddits and also the amount of distinct authors in every subreddit*/)
ON a.author=b.author
WHERE a.subreddit!=b.subreddit 
GROUP BY 1,3) AS final
WHERE final.percent > 10;