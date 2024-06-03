from sklearn.model_selection import ParameterGrid

dgp_params_grid_bartpy2 = {
    'n_trees': [10, 20, 50],
    'n_burn': [50, 100, 200],
    'n_samples': [100, 200, 500]
}



dataset_name = ["heart","breast_cancer","haberman",	"credit_g","csi_pecarn_prop","csi_pecarn_pred","juvenile_clean",
                "compas_two_year_clean","enhancer","fico","iai_pecarn_prop","iai_pecarn_pred","credit_card_clean","tbi_pecarn_prop",
                "tbi_pecarn_pred","readmission_clean"]
dgp_params_dict_list_bartpy2 = list(ParameterGrid(dgp_params_grid_bartpy2))
