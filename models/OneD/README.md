# File organization:
- Name the main file where the actual model resides as <model>_baseline_<keras2> or <_pytorch>.py
- <model>.py for the Benchmark class
- <model>_default_model.txt

Please follow the above conventions for naming files, all lowercase filenames.
`model_name` is a required keyword for all models.

This would enable the model a user to run `python oned_baseline_keras2.py`

Users never change parameters inside the file oned_baseline_keras2.py, any parameters needed for tweaking or optimizing the model
must be provide vi oned_default_model.txt
