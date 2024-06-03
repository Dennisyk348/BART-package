from sklearn.metrics import f1_score, roc_auc_score
from bartpy2.sklearnmodel import SklearnModel 
from sklearn.model_selection import train_test_split
import imodels
from time import time


def run_one_dgp_iter(dataset_names, model_params_dicts, metric=roc_auc_score,
                     ):
    results = []
    for dataset_name in dataset_names:

        X_train, X_test, y_train,y_test = make_dgp(dataset_name)
    
        
        for model_params_dict in model_params_dicts:
            model = make_model(model_params_dict)
            start_time = time()
            score = get_model_score(X_train, y_train, X_test, y_test, model, metric)
            time_elapsed = time() - start_time
            results.append({
                'dataset': dataset_name,
                'n_trees': model_params_dict['n_trees'],
                'n_burn': model_params_dict['n_burn'],
                'n_samples': model_params_dict['n_samples'],
                'time_elapsed': time_elapsed,
                'AUC': score
            })
    return results

def get_model_score(X_train, y_train, X_test, y_test, model, metric):
    model.fit(X_train, y_train)
    preds_test_prob = model.predict(X_test)
    y_pred = (preds_test_prob > 0.5).astype(int) 
    score = metric(y_test, y_pred)
    return score

def make_model(model_params_dict):
    model =  SklearnModel(**model_params_dict)
    return model

def make_dgp(dataset_name):
    X, y, feature_names = imodels.get_clean_dataset(dataset_name, data_source='imodels')
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.25, random_state=42)
    return X_train, X_test, y_train,y_test