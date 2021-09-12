from sys import argv

indirs = argv[1].split(" ")

outs = []
for indir in indirs:
    with open(indir, 'r') as f:
        OUT = f.read().split(',')
        new = {'dofs': OUT[0], 'cores': OUT[1], 'degree': OUT[2], 'method': OUT[3], 'nl_its': OUT[4], 'time': OUT[5], 'stress': OUT[6]}
        outs.append(new)

# For all methods, for all degrees append nl_its vs stress
out_robust = { 'Newton': {'1': [], '2':[]}, 'BFGS': {'1': [], '2':[]}}
for out in outs:
    if out['cores'] == '1':
        out_robust[out['method']][out['degree']].append((out['stress'][:-1], out['nl_its']))

for method in ['Newton', 'BFGS']:
    for degree in ('1','2'):
        print(out_robust)
        out_robust[method][degree].sort(key=lambda l: l[0])

print(out_robust)

