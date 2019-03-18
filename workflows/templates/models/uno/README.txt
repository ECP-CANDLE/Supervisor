Note this single change to uno_baseline_keras2.py (in this directory) from the one in Benchmarks/Pilot1/Uno:

-    unoBmk = benchmark.BenchmarkUno(benchmark.file_path, 'uno_default_model.txt', 'keras',
+    #mymodel_common = candle.Benchmark(file_path,os.getenv("DEFAULT_PARAMS_FILE"),'keras',prog='myprog',desc='My model')
+    unoBmk = benchmark.BenchmarkUno(benchmark.file_path, os.getenv("DEFAULT_PARAMS_FILE"), 'keras',
