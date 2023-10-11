# Perform Cross-Study Analysis

This workflow runs a cross-study analysis for drug-reponse prediction problem for varying source_datasets and target_datasets. The workflow is parameterized by the following variables:

1. source_dataset: The dataset used for training the model
2. target_dataset: The dataset used for testing the model
3. model_name: The name of the model to be trained (specified in testing script)
4. model_type: The type of the model to be trained (specified in testing script)
5. epochs: The number of epochs to train the model
6. split_nums: A list of split numbers to be used for training the model

### File index

- swift/workflow.{sh,swift}: Normal cross-study workflow

## Use from the supervisor tool

```
git clone https://github.com/ECP-CANDLE/Tests.git
cd Tests/sv-tool/cross-study-test/
$ supervisor lambda cross-study cfg-my-experiment-1.sh
```
