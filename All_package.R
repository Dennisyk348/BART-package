# library package
library(pROC)
library(bartMachine)
library(caret)
library(dbarts)
library(SoftBart)
library(BART)
library(e1071)

#invisible(Sys.setlocale("LC_TIME","en_US.UTF-8"))
# method for BART
bart_package <- function(train_x,train_y,test_x,test_y, num_trees_grid, alpha_grid, beta_grid) {
  
  results <- data.frame()
  
  
  for (num_trees in num_trees_grid) {
    for (alpha in alpha_grid) {
      for (beta in beta_grid) {
        
        # we can also add other parameters like ndpost: The number of posterior draws returned.
        # nskip:	Number of MCMC iterations to be treated as burn in.
        # and so on.
        t <- system.time({fit <- pbart(x.train = train_x,
                     y.train = train_y,
                     x.test = test_x,
                     ntree = num_trees,
                     base = alpha,
                     power = beta)})
        
        
        predictions <- colMeans(fit$yhat.test)
        # predictions is a logit
        y_pred <-  ifelse(sigmoid(predictions) > 0.5, 1, 0)
        time <- as.numeric(t["elapsed"])
        
        roc_result <- roc(test_y, y_pred)
        auc_score <- auc(roc_result)
        
        
        new_row <- data.frame(num_trees = num_trees, alpha = alpha, beta = beta,
                              time = time,auc_score = auc_score)
        
        
        results <- rbind(results, new_row)
      }
    }
  }
  
  return(results)
}

# method for dbarts
dbarts_package <- function(train_x,train_y,test_x,test_y, num_trees_grid, alpha_grid, beta_grid) {
  
  results <- data.frame()
  
  for (num_trees in num_trees_grid) {
    for (alpha in alpha_grid) {
      for (beta in beta_grid) {
        
        # parameter name is same as pbart
        t <- system.time({bart_model <- bart(
          x.train = train_x,
          y.train = train_y,
          x.test = test_x,
          ntree = num_trees,
          power = beta,
          base = alpha
          
        )})
        
        predictions <- colMeans(bart_model$yhat.test)
        # predictions is also logit
        y_pred <-  ifelse(sigmoid(predictions) > 0.5, 1, 0)
        
        time <- as.numeric(t["elapsed"])
        roc_result <- roc(test_y, y_pred)
        auc_score <- auc(roc_result)
        
        
        new_row <- data.frame(num_trees = num_trees, alpha = alpha, beta = beta, 
                              time = time,auc_score = auc_score)
        
        
        results <- rbind(results, new_row)
        
      }
    }
  }
  
  return(results)
}

# method for bartMachine

bartMachine_package <- function(train_x,train_y,test_x,test_y, num_trees_grid, alpha_grid, beta_grid) {
  
  results <- data.frame()
  
  for (num_trees in num_trees_grid) {
    for (alpha in alpha_grid) {
      for (beta in beta_grid) {
        
        # some other parameters like num_burn_in: Number of MCMC samples to be discarded as “burn-in”.
        # num_iterations_after_burn_in: Number of MCMC samples to draw from the posterior distribution
        bart_model <- bartMachine(
          X = train_x,
          y = train_y,
          num_trees = num_trees,
          beta = beta,
          alpha = alpha
          
        )
        # The value of calculating the time required for modeling
        time <- bart_model$time_to_build
        
        pred <- predict(bart_model,test_x)
        # pred is probability, not logit
        y_pred <-  ifelse(pred > 0.5, 1, 0)
        
        
        roc_result <- roc(test_y, pred)
        auc_score <- auc(roc_result)
        
        
        new_row <- data.frame(num_trees = num_trees, alpha = alpha, beta = beta,
                              auc_score = auc_score,time=time)
        
        
        results <- rbind(results, new_row)
        
      }
    }
  }
  
  return(results)
}

#method for softBart package
SoftBart_package <- function(train_x,train_y,test_x,test_y, num_trees_grid, alpha_grid, beta_grid) {
  
  results <- data.frame()

  for (num_trees in num_trees_grid) {
    for (alpha in alpha_grid) {
      for (beta in beta_grid) {
        
        # Hepers is a list for hyperparameters like gamma(alpha), beta, num_tree
        # opts is a list for MCMC options like num_burn, num_save(The number of samples to collect)
        t <- ({bart_model <- softbart(X = train_x, Y = train_y, X_test = test_x, 
                               hypers = Hypers(train_x, train_y, num_tree = num_trees, gamma = alpha,beta = beta),
                               opts = Opts(num_burn = 200, num_save = 1000, update_tau = TRUE))})
        
        
        predictions <- bart_model$y_hat_test_mean
        # predictions is already the probability
        y_pred <-  ifelse(predictions > 0.5, 1, 0)
        
        time <- as.numeric(t["elapsed"])
        roc_result <- roc(test_y, y_pred)
        auc_score <- auc(roc_result)
        
        
        new_row <- data.frame(num_trees = num_trees, alpha = alpha, beta = beta, auc_score = auc_score)
        
        
        results <- rbind(results, new_row)
        
      }
    }
  }
  
  return(results)
}

# Test for breast_cancer dataset

set.seed(316)
cancer <- read.csv("C:/Users/pyk/Desktop/nus/RA/project/imodels-data-master/data_cleaned/breast_cancer.csv")
x <- cancer[,-18]
y <- cancer[,18]

train_indices <- createDataPartition(y, p = 0.8, list = FALSE)
train_x <- x[train_indices, ]
test_x <- x[-train_indices, ]
train_y <- y[train_indices]
test_y <- y[-train_indices]

num_trees_grid <- c(50, 100, 200)  
alpha_grid <- c(0.9,0.95, 0.98)        
beta_grid <- c(2,3,5)

results <- bart_package(train_x ,train_y, test_x, test_y, num_trees_grid, alpha_grid, beta_grid)

results
