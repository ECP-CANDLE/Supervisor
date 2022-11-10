import unittest

import numpy as np
import uno_xcorr


# Run with: PYTHONPATH=UNO_BENCHMARK_PATH:BENCHMARK_COMMON_PATH python -m unittest tests.uno_sc
# E.g. PYTHONPATH=$HOME/Documents/repos/Benchmarks/Pilot1/Uno:$HOME/Documents/repos/Benchmarks/common
#   python -m unittest tests.uno_xcorr_tests
class TestUnoXcorr(unittest.TestCase):

    def setUp(self):

        if uno_xcorr.gene_df is None:
            dp = "./test_data/rescaled_combined_single_drug_growth.bz2"
            rp = "./test_data/combined_rnaseq_data_lincs1000_combat.bz2"
            uno_xcorr.init_uno_xcorr(rp, dp)

    def test_init(self):
        shape = (15198, 943)
        self.assertEqual(shape[0], uno_xcorr.gene_df.shape[0])
        self.assertEqual(shape[1], uno_xcorr.gene_df.shape[1])

        shape = (27769716, 7)
        self.assertEqual(shape[0], uno_xcorr.drug_df.shape[0])
        self.assertEqual(shape[1], uno_xcorr.drug_df.shape[1])

    def test_source(self):
        sources = ["CCLE", "CTRP", "GDC", "GDSC", "NCI60", "NCIPDM", "gCSI"]
        df_sources = uno_xcorr.gene_df["source"].unique()
        self.assertEqual(sources, list(df_sources))

    def test_xcorr(self):
        np.random.seed(42)
        drug_ids = uno_xcorr.drug_df.iloc[np.random.permutation(
            uno_xcorr.drug_df.shape[0])[:10000], :].DRUG_ID
        f = "./test_data/gene_out.txt"
        uno_xcorr.coxen_feature_selection("CCLE", "NCI60", 200, 200, drug_ids,
                                          f)
        with open(f) as f_in:
            lines = f_in.readlines()
        self.assertEquals(200, len(lines))


if __name__ == "__main__":
    unittest.main()
