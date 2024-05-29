library(BART)
library(pROC)
library(caret)

cancer <- read.csv("C:/Users/pyk/Desktop/nus/RA/project/imodels-data-master/data_cleaned/breast_cancer.csv")
x <- cancer[,-18]
y <- cancer[,18]

train_indices <- createDataPartition(y, p = 0.75, list = FALSE)
train_data <- cancer[train_indices, ]
test_data <- cancer[-train_indices, ]

grid_search_bart <- function(train_data,test_data, num_trees_grid, alpha_grid, beta_grid) {
  
  results <- data.frame()
  

  for (num_trees in num_trees_grid) {
    for (alpha in alpha_grid) {
      for (beta in beta_grid) {
        
        fit <- pbart(x.train = train_data[, -ncol(train_data)],
                     y.train = train_data[, ncol(train_data)],
                     x.test = test_data[, -ncol(test_data)],
                     ntree = num_trees,
                     base = alpha,
                     k = beta)
        
        
        predictions <- colMeans(fit$yhat.test)
        y_pred <-  ifelse(sigmoid(predictions) > 0.5, 1, 0)
        
        
        
        roc_result <- roc(test_data[, ncol(test_data)], y_pred)
        auc_score <- auc(roc_result)
        
        
        new_row <- data.frame(num_trees = num_trees, alpha = alpha, beta = beta, auc_score = auc_score)
        
        
        results <- rbind(results, new_row)
        
        
        
        #  results[[paste(num_trees, alpha, beta, sep = "_")]] <- list(
        #  num_trees = num_trees,
        #  alpha = alpha,
        #  beta = beta,
        #  AUC = auc_score 
        #)
      }
    }
  }
  
  return(results)
}



num_trees_grid <- c(10,20,50, 100, 200)  
alpha_grid <- c(0.8,0.90, 0.95)        
beta_grid <- c(2, 3,5)               

results <- grid_search_bart(train_data,test_data, num_trees_grid, alpha_grid, beta_grid)

results

