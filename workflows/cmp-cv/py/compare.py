CANDLE_DATA_DIR = os.getenv("CANDLE_DATA_DIR")
MODEL_NAME = os.getenv("MODEL_NAME")


def compare(exp_id, run_id):

    print(f"compare: run_id={run_id}")
    gParams = read_params(exp_id, run_id)
    model = gParams("model_name")

    directory = f"{CANDLE_DATA_DIR}/{model}/Output/{exp_id}/{run_id}"
    df_res = pd.read_csv(f"{directory}/test_predictions.csv")

    # a class to calculate errors for subsets of the validation/test set
    bmk = Benchmark(fp_path='drug_features.csv'
                   )  # TODO: have to have a drug features for a common test set
    subset_err = bmk.error_by_feature_domains_model(df_res, conditions)

    # collect results for comparison
    subset_err.set_index(
        'prop', inplace=True
    )  # TODO: use 'prop' as a parameter and move it to cmp_models.txt
    cmp_results[run_id] = subset_err.loc[
        cmp_prop,
        'error']  # this is the property based on which we want to do the comparison
    with open(f"{directory}/subset_err.txt", "w") as fp:
        fp.write(str(cmp_results[run_id]))
