"""This script can be used to filter a subset of the test set based on the
properties of the drug molecules.

For example, here we can select the molecules of which the 'prop' is
between two values (provided in the 2nd and 3rd elements of each list in
the conditions list. We can then find the prediction errors for this
domain. Knowledge of the errors of differnt molecular groups is helpful
to understand the currrent deficiencies of the drug response models (or
any molecular property prediction model in general). This knowledge is
then allow us to improve the models as well as use predictions from the
models which produce highly accurate preidictions for certain domains.
"""

import os
import pandas as pd
import pandas as pd
import numpy as np
from sklearn.metrics import mean_squared_error

# conditions = pd.DataFrame(
#     [['nAromAtom', 5, 10], ['nAtom', 20, 50], ['BertzCT', 800, 1000]],
#     columns=['prop', 'low', 'high'])
# case 2
conditions = pd.DataFrame(
    [
    ['nAtom', 8, 28],['nAtom', 28, 48],['nAtom', 48, 67],['nAtom', 67, 87],['nAtom', 87, 106],['nAtom', 106, 125],
    ['nAtom', 125, 145],['nAtom', 145, 164],['nAtom', 164, 184],['nAtom', 184, 203],['nAtom', 203, 222],
    ['nAtom', 222, 242],['nAtom', 242, 261],['nAtom', 261, 281],['nAtom', 281, 300],['nAtom', 300, 319],
    ['nAtom', 319, 339],['nAtom', 339, 358],['nAtom', 358, 378],['nAtom', 378, 397],['nAtom', 397, 416],
    ['nAtom', 416, 436],['nAtom', 436, 455],['nAtom', 455, 494],
    ['nAromAtom', 0, 3],['nAromAtom', 3, 6],['nAromAtom', 6, 10],['nAromAtom', 10, 13],
    ['nAromAtom', 13, 16],['nAromAtom', 16, 19],['nAromAtom', 19, 22],['nAromAtom', 22, 26],
    ['nAromAtom', 26, 29],['nAromAtom', 29, 32],['nAromAtom', 32, 35],['nAromAtom', 35, 38],
    ['nAromAtom', 38, 42],['nAromAtom', 42, 45],['nAromAtom', 45, 48],
    ['nRing', 0, 2],['nRing', 2, 3],['nRing', 3, 5],['nRing', 5, 6],
    ['nRing', 6, 8],['nRing', 8, 10],['nRing', 10, 11],['nRing', 11, 13],
    ['nRing', 38, 42],['nRing', 42, 45],['nRing', 45, 48],
    ['nAcid', 0, 1],['nAcid', 1, 2],['nAcid', 2, 3],['nAcid', 3, 4],
    ['BertzCT', 7.50964047e+00, 9.80918522e+02], ['BertzCT', 9.80918522e+02, 1.95422740e+03],
    ['BertzCT', 1.95422740e+03, 2.92753628e+03],['BertzCT', 2.92753628e+03, 3.90084517e+03],
    ['BertzCT', 3.90084517e+03, 4.87415405e+03],['BertzCT', 4.87415405e+03, 5.84746293e+03],
    ['BertzCT', 5.84746293e+03, 6.82077181e+03],['BertzCT', 6.82077181e+03, 7.79408069e+03],
    ['BertzCT', 7.79408069e+03, 8.76738957e+03],['BertzCT', 8.76738957e+03, 9.74069845e+03],
    ['nRot', 0, 10],['nRot', 10, 19],['nRot', 19, 29],['nRot', 29, 38],['nRot', 38, 48],
    ['nRot', 48, 58],['nRot', 58, 67],['nRot', 67, 77],['nRot', 77, 86],['nRot', 86, 96]
    ],
    columns=['prop', 'low', 'high'])

# from cmp_utils import conditions, Benchmark

CANDLE_DATA_DIR = os.getenv("CANDLE_DATA_DIR")


def compare(model_name, exp_id, run_id):
    cmp_results = {}
    print(f"compare: run_id={run_id}")
    # gParams = read_params(exp_id, run_id)
    # model = gParams("model_name")

    # model = "DrugCell"  # TODO: Hardcoded. have to get this from output dir?
    # turbine_output = os.getenv("TURBINE_OUTPUT")

    CANDLE_DATA_DIR = os.getenv("CANDLE_DATA_DIR")
    outdir = os.path.join(CANDLE_DATA_DIR, model_name, "Output", exp_id, run_id)
    directory = outdir
    # directory = f"{CANDLE_DATA_DIR}/Output/{exp_id}/{run_id}"
    print("reading the predictions....")
    df_res = pd.read_csv(f"{directory}/test_predictions.csv")

    # a class to calculate errors for subsets of the validation/test set
    print("reading the drug feature file....")
    # TODO: Should have to save the above file in this file
    # copy and place the following in your CANDLE_DATA_DIR
    # cp /lambda_stor/homes/ac.gpanapitiya/ccmg-mtg/benchmark/drug_features.csv .
    # bmk = Benchmark(fp_path=f'{CANDLE_DATA_DIR}/drug_features.csv'
    #                )  # TODO: have to have a drug features for a common test set
    # subset_err, final_domain_err = bmk.error_by_feature_domains_model(
    #     df_res, conditions)

    # # or this
    fp_path=f'{CANDLE_DATA_DIR}/drug_features.csv'
    subset_err, final_domain_err = error_by_feature_domains_model(fp_path, df_res, conditions)

    # collect results for comparison
    # cmp_prop = 'nAtom'  # TODO: Get this from gParameters
    # subset_err.set_index(
    #     'prop', inplace=True
    # )  # TODO: use 'prop' as a parameter and move it to cmp_models.txt
    # cmp_results[run_id] = subset_err.loc[
    #     cmp_prop,
    #     'error']  # this is the property based on which we want to do the comparison
    cmp_results[run_id] =  -1 # for case 2, this is not defined
    # # cmp_results[run_id] =  -1 # set to -1 for now as we don't have the drug features file
    # with open(f"{directory}/subset_err.txt", "w") as fp:
    #     fp.write(str(cmp_results[run_id]))

    subset_err.to_csv(f"{directory}/domain_err.csv", index=False)

    return str(cmp_results[run_id])


def error_by_feature_domains_model(fp_path, preds, conditions):

    fps = pd.read_csv(fp_path)
    report = []
    preds['err'] = abs(preds['true'] - preds['pred'])
    keep = preds.copy()
    for i in range(conditions.shape[0]):

        prop = conditions.loc[i, 'prop']
        low = conditions.loc[i, 'low']
        high = conditions.loc[i, 'high']

        locs = np.logical_and(fps[prop] <= high, fps[prop] > low)
        smiles = fps.loc[locs, 'smiles'].values
        tmp = preds[preds.smiles.isin(smiles)]
        mean_err = tmp.err.mean()

        report.append([prop, low, high, mean_err])

        keep = keep[keep.smiles.isin(smiles)] # this is in case we want to progressively
                                            # consider domains. A domain composed of multiple domains

    final_domain_err = keep.err.mean()  # return this
    report = pd.DataFrame(report, columns=['prop', 'low', 'high', 'error'])
    return report, final_domain_err


class Benchmark:

    def __init__(self, fp_path):

        self.fps = pd.read_csv(fp_path)
        # self.model_preds = model_preds
        # self.feature_conditions = feature_conditions
        self.reports = {}

    def error_by_feature_domains_model(self, preds, conditions):

        fps = self.fps
        report = []
        preds['err'] = abs(preds['true'] - preds['pred'])
        keep = preds.copy()
        for i in range(conditions.shape[0]):

            prop = conditions.loc[i, 'prop']
            low = conditions.loc[i, 'low']
            high = conditions.loc[i, 'high']

            locs = np.logical_and(fps[prop] <= high, fps[prop] > low)
            smiles = fps.loc[locs, 'smiles'].values
            tmp = preds[preds.smiles.isin(smiles)]
            mean_err = tmp.err.mean()

            report.append([prop, low, high, mean_err])

            keep = keep[keep.smiles.isin(smiles)]

        final_domain_err = keep.err.mean()  # return this
        report = pd.DataFrame(report, columns=['prop', 'low', 'high', 'error'])
        return report, final_domain_err

    def error_by_feature_domains(self, feature_conditions):

        results = []
        for model_name, pred in self.model_preds.items():

            report = self.error_by_feature_domains_model(
                pred, feature_conditions)
            report.loc[:, 'model'] = model_name
            results.append(report)

        results = pd.concat(results, axis=0)
        results = results.loc[:, ['model', 'prop', 'low', 'high', 'error']]
        results.reset_index(drop=True, inplace=True)

        return results

    def rank_by_acc(self, metric='rmse', th=3):

        results = {}
        for model_name, pred in self.model_preds.items():
            sub = pred[pred.labels > th]
            rmse = mean_squared_error(y_true=sub['labels'],
                                      y_pred=sub['preds'])**.5

            results[model_name] = {'rmse': rmse}

        results = pd.DataFrame.from_dict(results)
        results = results.T
        return results


def create_grid_files():

    dc_grid = {'epochs': [1, 2], 'lr': [1e-2, 1e-3]}
    sw_grid = {'epochs': [3, 4], 'lr': [1e-2, 1e-5]}

    with open('DrugCell_grid.json', 'w') as fp:
        json.dump(dc_grid, fp)

    with open('SWnet_CCLE_grid.json', 'w') as fp:
        json.dump(sw_grid, fp)
