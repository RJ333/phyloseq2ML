# use random forest as it understands negative values and categorical data

library(ggplot2)
library(phyloseq2ML)

names(splitted_keras_binary)
n_copies <- 5
original <- splitted_keras_binary
oversampled_test <- oversample(splitted_keras_binary, n_copies, 0.00)

# check the effect of oversampling
example_set <- oversampled_test[[2]][["train_set"]]
target <- names(example_set[ncol(example_set)])
# samples as rows
orig_cols <- names(example_set[-ncol(example_set)])
full_meta_data <- phyloseq::sample_data(testps)
oversampled_meta_data <- full_meta_data[rep(seq_len(nrow(full_meta_data)), 
  each = 1 + n_copies), ]

# do I need this part? only if I want to subset before random Forest
# remove duplicate meta data columns
duplicates <- intersect(names(example_set),names(oversampled_meta_data))

oversampled_meta_data <- oversampled_meta_data[, !names(oversampled_meta_data) %in% duplicates]
merged_before <- merge(example_set, oversampled_meta_data, by = "row.names")
row.names(merged_before) <- merged_before$Row.names
merged_before$Row.names <- NULL

#exam_V4 <- subset(merged_before, Primerset == "V4")
#exam_V4_clean <- exam_V4[, colSums(exam_V4 != 0, na.rm = TRUE) > 0]

# only V4 data available in package training set, duh
exam_V4_clean <- merged_before
exam_V4_clean$replicate <- sapply(strsplit(row.names(exam_V4_clean), "\\."), "[", 2)

mtry_factor <- 5
all_vars <- ncol(example_set)
for_mtry <- ifelse((sqrt(all_vars) * mtry_factor) < all_vars,
  sqrt(all_vars) * mtry_factor, all_vars)
forest <- randomForest::randomForest(exam_V4_clean[, orig_cols], proximity = TRUE, ntree = 1000, 
  mtry = for_mtry)

distance_matrix <- dist(1 - forest$proximity)
PCA_object <- cmdscale(distance_matrix, eig = TRUE, x.ret = TRUE)
# calculate percentage of variation for x and y axis
PCA_variation <- round(PCA_object$eig/sum(PCA_object$eig) * 100, 1)
# format data
PCA_values <- PCA_object$points
PCA_data <- data.frame(Sample = rownames(PCA_values),
                           X = PCA_values[, 1],
                           Y = PCA_values[, 2])

merged_after <- merge(PCA_data, exam_V4_clean, by = "row.names")

ggplot(merged_after, aes(X, Y, colour = replicate)) +
  geom_point(pch = 21, size = 3, stroke = 1.5, alpha = 0.8) +
  geom_polygon(aes(fill = !!target, group = Extraction_ID), alpha = 0.7) +
  #geom_text(aes(label = Row.names), size = 1.5, colour = "black") +
  labs(x = paste("PC1 - ", PCA_variation[1], "%", sep = ""),
    y = paste("PC2 - ", PCA_variation[2], "%", sep = ""))
