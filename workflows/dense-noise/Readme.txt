# For running the cmp workflow
# Output Files
## When launching the model from the dense_noise folder, experiments directory is created and all the "cmp" model level logging is saved in experiments directory
Example:
dense_noise/experiments/
EXP024/
├── 1000-050.00-04
│   ├── cmp
│   │   └── Output
│   │       └── EXP000
│   │           └── RUN000
│   │               └── final_params.txt
│   ├── model.log

## Results for the two uno models launched by cmp are saved in the CANDLE_DATA_DIR directory
/lus/grand/projects/CSC249ADOA01/jain/cdd/
├── cmp
│   ├── Data
│   └── Output
│       └── EXP024
│           └── 1000-050.00-04-M0
│               └── cmp-0.log
├── Pilot1
│   ├── Combined_PubChem_dragon7_descriptors.tsv
│   ├── combined_rnaseq_data_lincs1000_source_scale
│   ├── combined_single_response_agg
│   ├── drug_info
│   └── NCI60_dragon7_descriptors.tsv
└── Uno
    └── Output
        └── EXP024
            └── 1000-050.00-04-M0
                └── model.log
