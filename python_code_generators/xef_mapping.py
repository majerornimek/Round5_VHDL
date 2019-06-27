
def xef_mapping_gen(kappa):
    for i in range(kappa):
        print("DIN("+str(kappa*8-(i)*8-1), "downto", str(kappa*8-(i+1)*8)+") when \""+'0'*(5-len(bin(i)[2:]))+str(bin(i)[2:])+"\",")

def xef_reg_recomputed(kappa, p):
    xef_reg = [[ 16, 11, 13, 16, 17, 19, 21, 23, 25, 29],
        [ 24, 13, 16, 17, 19, 21, 23, 25, 29, 31 ],
        [ 16, 16, 17, 19, 21, 23, 25, 29, 31, 37 ]]

    for i in range(kappa):
        print(i)
        l = []
        for j in range(1,10):
            l.append(i*8%xef_reg[p][j])
        print(l)



if __name__ == "__main__":

    #xef_mapping_gen(32)
    xef_reg_recomputed(32,2)