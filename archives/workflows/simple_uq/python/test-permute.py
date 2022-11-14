import permute

size = 10
validation = 2
permute.configure(seed=10101, size=size, training=size - validation)

for i in range(0, 9):
    training = permute.get()
    validation = permute.validation(size, training)
    print str(training) + " " + str(validation)
