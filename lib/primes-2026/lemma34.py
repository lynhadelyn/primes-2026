import itertools
Sym = SymmetricFunctions(QQ)
e = Sym.elementary()

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

#Given n and k with n >= k and length mlen >= k, check if any two partitions give the same output
def prek_injectivity(n,k,mlen):
    lambdas = Partitions(n, min_length = mlen, max_length = mlen)
    outputs = {}
    for lam in lambdas:
        preek = prek(lam,k)
        prev = outputs.get(tuple(preek))
        if prev is not None:
            print(prev)
            print(lam)
            print(f"Injectivity fails with {n}, pre{k}, partition length {mlen}, and output {preek}")
            return False
        outputs[tuple(preek)] = lam
    return True

#Lemma 3.4 testing
a1 = [0,1,2,3]
a2 = [0,1,2]
X = [1,5,7,11]
for a in a1:
    for b in a2:
        for x in X:
            y = 2**a * 3**b * x
            if y > 18:
                print(y)
                print(prek_injectivity(y,3,3))
