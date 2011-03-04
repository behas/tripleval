# load the ggplot2 package (http://had.co.nz/ggplot2/)
library(ggplot2)

result_files <- c("4store.csv", "Virtuoso.csv", "JenaTDB.csv", "JenaSDB.csv")

# calculate the results for each triple store

results = list()

for(i in 1:length(result_files)) {
  
  # extracting the triple store name from the .csv file
  ts_name <- strsplit(result_files[i], ".", fixed="TRUE")[[1]][1]
  
  cat("Calculating results for triple store: ", ts_name, "\n")
  
  # reading the experiment result file
  ts_data <- read.csv(file=result_files[i], head=TRUE, sep=",")
  
  # calculate the average over all iterations
  ts_data <- ddply(ts_data, .(file), colwise(mean, .(triples, loadTime, query1, query2)))
  
  # add cumulative triple sum and cumulative ingest time to result frame
  result <- cbind(ts_data[,1:2],
                  storedTriples=cumsum(ts_data$triples),
                  loadTime=ts_data[,3],
                  cumloadTime=cumsum(ts_data$loadTime),
                  ts_data[,4:5])
  
  # append the results for this triple store to the results list
  results[[ts_name]] <- result
  
}

# merging individual triple store results into a single data frame
all_data <- ldply(results)

# rename the .id column to "Triple Store"
names(all_data)[names(all_data)==".id"] <- "RDF_Store"

# adapting the number of stored triples to million scale
all_data[["storedTriples"]] <- sapply(all_data[["storedTriples"]], function(x) x/1000000)

# adapting the cumulative load time to minute scale
all_data[["cumloadTime"]] <- sapply(all_data[["cumloadTime"]], function(x) x/60)

#print(all_data)


p1 <- ggplot(all_data, aes(storedTriples, cumloadTime, color = RDF_Store, linetype = RDF_Store)) +
      geom_line() +
      opts(title = "Triple Load Performance") +
      xlab("Loaded Triples (in millions)") +
      ylab("Cumulative Ingest Time (in minutes)")

# p1 <- qplot(storedTriples, cumloadTime, data=all_data, 
#   geom="line", colour=.id,
#   main="Triple Load Performance", xlab="Loaded Triples (in millions)", ylab="Cumulative Ingest Time (in minutes)") +
#   scale_colour_discrete("Triple Store")

p2 <- ggplot(all_data, aes(storedTriples, query1, color = RDF_Store, linetype = RDF_Store)) +
      geom_line() +
      opts(title = "Describe Query Performance") +
      xlab("Loaded Triples (in millions)") +
      ylab("Query Response Time (in seconds)")
  
# p2 <- qplot(storedTriples, query1, data=all_data, 
#   geom="line", colour=.id,
#   main="Describe Query Performance", xlab="Loaded Triples  (in millions)", ylab="Query Response Time (in seconds)") + 
#   scale_colour_discrete("Triple Store")
# 

p3 <- ggplot(all_data, aes(storedTriples, query2, color = RDF_Store, linetype = RDF_Store)) +
      geom_line() +
      opts(title = "Select Query Performance") +
      xlab("Loaded Triples (in millions)") +
      ylab("Query Response Time (in seconds)")


# p3 <- qplot(storedTriples, query2, data=all_data, 
#   geom="line", colour=.id,
#   main="Select Query Performance (single label)", xlab="Loaded Triples  (in millions)", ylab="Query Response Time (in seconds)") + 
#   scale_colour_discrete("Triple Store")
# 

# print plots to screen
print(p1)
print(p2)
print(p3)

# output plots as PDF
ggsave(p1, file="ts_load_time.pdf")
ggsave(p2, file="ts_describe_query_time.pdf")
ggsave(p3, file="ts_label_query_time.pdf")



