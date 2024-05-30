library(dbarts)
library(PROC)

cancer <- read.csv("C:/Users/pyk/Desktop/nus/RA/project/imodels-data-master/data_cleaned/breast_cancer.csv")
x <- cancer[,-18]
y <- cancer[,18]

train_indices <- createDataPartition(y, p = 0.75, list = FALSE)
train_x <- x[train_indices, ]
test_x <- x[-train_indices, ]
train_y <- y[train_indices]
test_y <- y[-train_indices]


grid_search_bart <- function(train_x,train_y,test_x,test_y, num_trees_grid, alpha_grid, sample_grid) {
  
  results <- data.frame()
  
  
  for (num_trees in num_trees_grid) {
    for (alpha in alpha_grid) {
      for (sample in sample_grid) {
        
        bart_model <- bart(
          x.train = train_x,
          y.train = train_y,
          x.test = test_x,
          ntree = num_trees,
          ndpost = sample,
          base = alpha
          
        )
        
        
        predictions <- colMeans(bart_model$yhat.test)
        y_pred <-  ifelse(sigmoid(predictions) > 0.5, 1, 0)
        
        
        
        roc_result <- roc(test_y, y_pred)
        auc_score <- auc(roc_result)
        
        
        new_row <- data.frame(num_trees = num_trees, alpha = alpha, sample = sample, auc_score = auc_score)
        
        
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


results <- grid_search_bart(train_x ,train_y, test_x, test_y, num_trees_grid, alpha_grid, sample_grid)

results


