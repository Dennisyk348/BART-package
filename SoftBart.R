library(SoftBart)
library(scales)
library(pROC)
library(caret)

cancer <- read.csv("C:/Users/pyk/Desktop/nus/RA/project/imodels-data-master/data_cleaned/breast_cancer.csv")
x <- cancer[,-18]
y <- cancer[,18]

train_indices <- createDataPartition(y, p = 0.75, list = FALSE)
train_x <- x[train_indices, ]
test_x <- x[-train_indices, ]
train_y <- y[train_indices]
test_y <- y[-train_indices]

## Fit the model
fit <- softbart(X = train_x, Y = train_y, X_test = test_x, 
                hypers = Hypers(train_x, train_y, num_tree = 50, alpha = 0.8,beta = 2),
                opts = Opts(num_burn = 200, num_save = 2000, update_tau = TRUE))
predictions <- fit$y_hat_test_mean
y_pred <-  ifelse(predictions > 0.5, 1, 0)
test_y
y_pred
roc_result <- roc(test_y, y_pred)
auc_score <- auc(roc_result)


grid_search_bart <- function(train_x,train_y,test_x,test_y, num_trees_grid, alpha_grid, beta_grid) {
  
  results <- data.frame()
  
  
  for (num_trees in num_trees_grid) {
    for (alpha in alpha_grid) {
      for (beta in beta_grid) {
        
        bart_model <- softbart(X = train_x, Y = train_y, X_test = test_x, 
                               hypers = Hypers(train_x, train_y, num_tree = num_trees, alpha = alpha,beta = beta),
                               opts = Opts(num_burn = 200, num_save = 1000, update_tau = TRUE))
        
        
        predictions <- bart_model$y_hat_test_mean
        y_pred <-  ifelse(predictions > 0.5, 1, 0)
        
        
        roc_result <- roc(test_y, y_pred)
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

num_trees_grid <- c(50, 100, 200)  
alpha_grid <- c(0.5,0.75, 0.98)        
beta_grid <- c(2,3,5)
sample_grid <- c(1000,1200,1500,1800)


results <- grid_search_bart(train_x ,train_y, test_x, test_y, num_trees_grid, alpha_grid, beta_grid)

results