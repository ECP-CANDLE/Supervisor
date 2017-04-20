import p1b1_runner, os


def main():
    data_directory = os.path.dirname(os.path.realpath(__file__))
    # should load the data
    p1b1_runner.run(data_directory, "2")
    # data should now be loaded
    assert p1b1_runner.X_train is not None
    assert p1b1_runner.X_test is not None
    p1b1_runner.run(data_directory, "2")

if __name__ == '__main__':
    main()
