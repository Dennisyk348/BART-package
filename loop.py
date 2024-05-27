from bartpy2.sklearnmodel import SklearnModel 
from sklearn.metrics import f1_score, roc_auc_score
from tqdm import tqdm
from parameter import dgp_params_dict_list_bartpy2, dataset_name
from sim_util import run_one_dgp_iter
n_iter = 5
def bartpy2(dataset_name,dgp_params_dict_list_bartpy2, metric=roc_auc_score,
         n_iter=n_iter):
    results = []
    for iter_num in tqdm(range(n_iter)):
        results+= run_one_dgp_iter(dataset_name, dgp_params_dict_list_bartpy2)
        
    return results

bartpy2(['breast_cancer'],dgp_params_dict_list_bartpy2,n_iter)