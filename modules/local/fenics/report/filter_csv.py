from sys import argv

indirs = argv[1].split(" ")
OUTDIR = argv[2]
OUT_ROBUST="robustness.csv"
OUT_SCALAB="scalability.csv"

def dict_to_csv(_dict, prefix, header):
    for method in _dict:
        for degree in _dict[method]:
            filename = "{}/{}_{}_{}.csv".format(OUTDIR,prefix,method[0], degree)
            outputs = _dict[method][degree]
            print(outputs)
            with open(filename, 'w') as f:
                f.write(header)
                for line in outputs:
                    f.write("\n{},{}".format(line[0], line[1]))


outs = []
for indir in indirs:
    with open(indir, 'r') as f:
        OUT = f.read().split(',')
        new = {'dofs': OUT[0], 'cores': OUT[1], 'degree': OUT[2], 'method': OUT[3], 'nl_its': OUT[4], 'time': OUT[5], 'stress': OUT[6][:-1]}
        outs.append(new)

# For all methods, for all degrees append nl_its vs stress
out_robust = { 'Newton': {'1': [], '2':[]}, 'BFGS': {'1': [], '2':[]}}
for out in outs:
    if out['cores'] == '16':
        out_robust[out['method']][out['degree']].append((out['stress'], out['nl_its']))

for method in ['Newton', 'BFGS']:
    for degree in ('1','2'):
        out_robust[method][degree].sort(key=lambda l: float(l[0]))

print(out_robust)
dict_to_csv(out_robust, "ROBUST", "nl_its,stress")

# For all methods, for all degrees append time vs cores
out_scalab = { 'Newton': {'1': [], '2':[]}, 'BFGS': {'1': [], '2':[]}}
for out in outs:
    print(out)
    if out['stress'] == '1e4':
        out_scalab[out['method']][out['degree']].append((out['cores'], out['time']))

for method in ['Newton', 'BFGS']:
    for degree in ('1','2'):
        out_scalab[method][degree].sort(key=lambda l: l[0])

print(out_scalab)
dict_to_csv(out_scalab, "SCALAB", "cores,time")


