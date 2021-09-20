#!/bin/bash
# This script runs the simulation for a given parameter set 
# and stores the filtered output in the given output file
# Inputs:
# 1: Cores
# 2: Module directory
# 3: FEM degree
# 4: Method
# 5: Stress
# 6: Mesh file
# 7: outdir name
# 8: output file

# Filter input
CORES=$1
MODSDIR=$2
DEGREE=$3
METHOD=$4
STRESS=$5
MESH=$6
OUTDIR=$7
OUTFILE=$8  # B-1-1-5e3.out

mpirun -np ${CORES} python3 ${MODSDIR}/Mechanics.py "${DEGREE}" "${METHOD}" "${STRESS}" "${MESH}" "${OUTDIR}" > TEMP 

grep 'nonlinear' TEMP | sed -E 's/.*in ([0-9]+) nonlinear.*/\1/g' > NL_ITS
grep 'nonlinear' TEMP | sed -E 's/.* ([0-9]+\.[0-9]+)s.*/\1/g' > TIMES
DOFS=$(grep 'Dofs' TEMP | sed -E 's/.*Dofs = ([0-9]+).*/\1/g')
NL_IT=$(python3 ${MODSDIR}/column_average.py NL_ITS)
TIME=$(python3 ${MODSDIR}/column_average.py TIMES)
echo $DOFS,$CORES,$DEGREE,$METHOD,$NL_IT,$TIME,$STRESS > $OUTFILE
rm TEMP NL_ITS TIMES
