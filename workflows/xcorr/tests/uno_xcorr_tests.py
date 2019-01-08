import unittest
import uno_xcorr

# Run with: PYTHONPATH=UNO_BENCHMARK_PATH:BENCHMARK_COMMON_PATH python -m unittest tests.uno_sc
# E.g. PYTHONPATH=$HOME/Documents/repos/Benchmarks/Pilot1/Uno:$HOME/Documents/repos/Benchmarks/common 
#   python -m unittest tests.uno_xcorr_tests
class TestUnoXcorr(unittest.TestCase):

    def setUp(self):
        if uno_xcorr.gene_df is None:
            uno_args = {'ncols' : None, 'scaling' : 'std',
            'use_landmark_genes' : True, 'use_filtered_genes' : False,
            'preprocess_rnaseq' : None}

            uno_xcorr.init_uno_xcorr(uno_args)

    def test_init(self):
        shape = (15196, 944)
        self.assertEqual(shape[0], uno_xcorr.gene_df.shape[0])
        self.assertEqual(shape[1], uno_xcorr.gene_df.shape[1])

    def test_source(self):
        sources = ['CCLE', 'CTRP', 'GDC', 'GDSC', 'NCI60', 'NCIPDM', 'gCSI']
        df_sources = uno_xcorr.gene_df['source'].unique()
        self.assertEqual(sources, list(df_sources))

    def test_source_selection(self):
        sources = {'CCLE' : (1018, 942),
                    'CTRP' : (812, 942),
                    'GDC' : (11081, 942),
                    'GDSC' : (670, 942),
                    'NCI60' : (60, 942),
                    'NCIPDM' : (1198, 942),
                    'gCSI' : (357, 942)}
        for k,v in sources.items():
            df = uno_xcorr.select_features(source=k)
            self.assertEqual(v, df.shape)

    def test_xcorr(self):
        uno_xcorr.compute_cross_correlation('CCLE', 'NCI60', 0.0, "./foo/bar/genes.txt")

        
if __name__ == '__main__':
    unittest.main()
