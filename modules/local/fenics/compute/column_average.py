from sys import argv

filename = argv[1] # 0 is script name
result = 0.0
with open(filename, 'r') as f:
    lines = f.readlines()
    count = 0
    for l in lines:
        result += float(l)
        count += 1 

print(result/count)
