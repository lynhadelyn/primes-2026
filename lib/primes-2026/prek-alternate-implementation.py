import itertools
#Compatible with SageMath 7.5. May not work on newer versions of SageMath.

#Given lambda a partition of n and some k, produce some elementary symmetric function ek
#return a list of its summands evaluated at the values given by parts of lambda
def prek(lam, k):
    l = len(lam)
    ek = e([k]).expand(l)
    zero_to_l_minus_one = [i for i in range(l)]
    #choose indices of entries of lam NOT to zero out
    nonzeros = list(itertools.combinations(zero_to_l_minus_one,k))
    #to be plugged into ek
    inputs = []
    output = []
    for nonzero in nonzeros:
        #create length l string of parts of lam at indices indicated by nonzeros and zeroes at all other indices
        input_list = []
        for i in range(l):
            to_add = 0
            if i in nonzero:
                to_add = 1
                to_add*=lam[i]
            input_list.append(to_add)
        inputs.append(input_list)
    for inpu in inputs:
        output.append(ek(inpu))
    return sorted(output, reverse=True)



#Given n and k with n >= k, print all partitions of n and their evaluations under prek
def prek_printer(n,k,minlen, maxlen):
    lambdas = Partitions(n, min_length = minlen, max_length = maxlen)
    for lam in lambdas:
        preek = prek(lam,k)
        print(f"pre{k} of {lam}: {preek}")
    return None
#prek_printer(9,3,3,9)

#Given n and k with n >= k and length mlen >= k, check if any two partitions give the same output
def prek_injectivity(n,k,mlen):
    lambdas = Partitions(n, min_length = mlen, max_length = mlen)
    outputs = []
    for lam in lambdas:
        preek = prek(lam,k)
        if preek in outputs:
            print(lam)
            print(f"Injectivity fails with {n}, pre{k}, partition length {mlen}, and output {preek}")
            return False
        outputs.append(preek)
    return True

for k in range(3,10):
    for n in range(k,20):
        for mlen in range(k+1,n):
            print(f"k = {k}, n = {n}, partition length = {mlen}")
            print(prek_injectivity(n,k,mlen))
