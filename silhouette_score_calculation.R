library(cluster)
data(iris)
data <- iris[, 1:4]

k <- 3
set.seed(123)
km <- kmeans(data, k)
distance <- as.matrix(dist(data))

check_empty_clusters <- function(cluster_table) {
  empty_clusters <- which(cluster_table == 0)
  if (length(empty_clusters) > 0) {
    stop(paste("Error: empty clusters detected at indices", empty_clusters))
  }
}

cluster_sizes <- table(km$cluster)
check_empty_clusters(cluster_sizes)

mean_cluster_distance <- function(point, cluster, distances) {
  cluster_distances <- distances[point, cluster]
  if (length(cluster_distances) == 0) {
    return(Inf)
  } else {
    return(mean(cluster_distances))
  }
}

get_min_mean_distance <- function(point, cluster, cluster_sizes, distances, km) {
  other_clusters <- setdiff(unique(km$cluster), cluster)
  other_cluster_sizes <- cluster_sizes[other_clusters]
  other_cluster_distances <- sapply(other_clusters, mean_cluster_distance, point = point, distances = distances)
  other_cluster_distances[is.na(other_cluster_sizes) | other_cluster_sizes == 0] <- Inf
  return(min(other_cluster_distances))
}

rows <- nrow(data)
Si <- numeric(rows)

for (i in 1:rows) {
  ci <- km$cluster[i]
  a <- sum(distance[i, km$cluster == ci]) / (sum(km$cluster == ci) - 1)
  
  cluster_sizes[ci] <- cluster_sizes[ci] - 1
  b <- get_min_mean_distance(i, ci, cluster_sizes, distance, km)
  cluster_sizes[ci] <- cluster_sizes[ci] + 1
  
  Si[i] <- (b - a) / max(a, b)
}

silhouette_score <- mean(Si, na.rm = TRUE)
cat("The silhouette score is:", silhouette_score, "\n")
