library(e1071)

# number of classes
k = 3

# number of elements of A
na = 50
# number of elements of B
nb = 50

nc = 50

# total overlap
pa = (na * 1/k)/na
pb = (nb * 1/k)/nb
pc = (nb * 1/k)/nb

# no overlap
pa = (na * 1)/na
pb = (nb * 1)/nb
pc = (nc * 1)/nc

si = 1/k * pa + 1/k * pb + 1/k * pc

# intermediate overlap
#n_over = 20
si_l = c()
for(n_over in 2:na)
{
    xa = rep(1, na)
    xb = rep(1, nb)
    xc = rep(1, nc)

    tn = seq(1/n_over, 1 - 1/n_over, length.out=n_over)
    #tn = sigmoid(seq(-2, 2, length.out=n_over))

    xa[1:n_over] = tn
    xb[1:n_over] = tn
    xc[1:n_over] = tn
    xc[(nc-n_over+1):nc] = tn

    pa = sum(xa)/na
    pb = sum(xb)/nb
    pc = sum(xc)/nb

    # separability index
    si = 1/k * pa + 1/k * pb + 1/k * pc
    print(si)
    si_l = c(si_l, si)
}

