import os

import numpy as np


def make_fake_data(out_dir):
    numF = 10  # Number of features
    numS = 50  # Number of samples to be multiplied by 2
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)
    for j in range(6):
        data1 = np.random.randn(numF, numS)
        for i in range(numF):
            data1[i, :] = data1[i, :] + i / 5
        data2 = np.random.randn(numF, numS)
        data1 = np.hstack((data1, data2))
        data1 = np.transpose(data1)
        data3 = np.random.randn(numF, int(numS / 2))
        for i in range(numF):
            data3[i, :] = data3[i, :] + i / 5
        data4 = np.random.randn(numF, int(numS / 2))
        data3 = np.hstack((data3, data4))
        data3 = np.transpose(data3)

        np.savetxt("{}/data{}.tsv".format(out_dir, j * 2),
                   data1,
                   delimiter="\t")
        np.savetxt("{}/data{}.tsv".format(out_dir, j * 2 + 1),
                   data3,
                   delimiter="\t")


if __name__ == "__main__":
    make_fake_data("./test_data")
