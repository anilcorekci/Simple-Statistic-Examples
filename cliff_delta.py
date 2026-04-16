import numpy as np

#Tau-b: Keeps the "person" together (Correlation).
#Cliff's Delta: Keeps the "groups" separate (Comparison).


def pairwise_signs(A, B):
#look every element in A within every element of B
    for a in A:
        for b in B:
            yield int(a > b) - int(a < b)
# yield here returns the logical result 
# > think like a #spill in excel on the whole
# transformed as int from boolean
# boolean False int > -1
# boolean True int > 1

def cliff_delta(x, y):
 #   print(*pairwise_signs(x, y))
    delta = sum(pairwise_signs(x, y)) / (len(x)*len(y))
    return delta

def bootsrap(x, y, b=1000):

    # conduct boot sampling default by 1000
    # *kwarg "b" for changing the number of sampling

    nx = len(x)
    ny =  len(y)
    #   b = 1000 # Increased slightly for testing
    boot_tau = np.zeros(b)

    for i in range(b):
        indices = np.random.randint(0, nx, nx)
        boot_x = x[indices]

        indices = np.random.randint(0, ny, ny)
        boot_y = y[indices]

        cliff_manual = cliff_delta(boot_x, boot_y)
        boot_tau[i] = cliff_manual

        cliff_manual = cliff_delta(boot_x, boot_y)
        print(f"Manual: {cliff_manual:.6f}")
        # time.sleep(0.01)
        #  tau_scipy = stats.kendalltau(boot_x, boot_y).statistic
        #  print(f"Manual: {tau_manual:.6f} | SciPy: {tau_scipy:.6f} | Diff: {abs(tau_manual - tau_scipy):.2e}")

    c_lower = np.percentile(boot_tau, 2.5)
    c_upper = np.percentile(boot_tau, 97.5)
    # return CI por 95%
    cliff_manual = cliff_delta(x, y)
    print("Confidence interval via bootstrapping ",b, " samples")
    print (" Lower CI:", c_lower, "\n Upper CI:", c_upper, "\n Manual", cliff_manual )

#-----main-data----------------#

x = np.array([8.5,4,7,5.5,8,6.5,5,7.5,4.5])
y = np.array([5,4,7,9,9,8,3.5,8,7,9,9,8])

bootsrap(x, y, 10)
