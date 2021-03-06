#!/usr/bin/env python

from time import time
from lib.Fibers import generateFibers
from lib.GLOBAL_VARIABLES import *
from lib.MeshCreation import prolateGeometry
from lib.MechanicsSolver import MechanicsSolver
from lib.Markers import MarkersSolid
from lib.Parameters import PhysicalParametersSolid, OutputParameters
from petsc4py import PETSc
from sys import argv
assert len(argv) == 6, "Must give five arguments: FEM degree, method (Newton|BFGS), active stress value, mesh file name (no extension), output file name"

degree = int(argv[1])
method = argv[2]
stress = float(argv[3])  # 5e3

parameters["form_compiler"]["optimize"] = True
parameters["form_compiler"]["cpp_optimize"] = True

name = argv[5] # "heartbeat"
geom = argv[4] # prolate_h4_v2_ASCII or prolate_4mm
export = True
LBFGS_order = 50

mesh, markers, ENDOCARD, EPICARD, BASE, NONE = prolateGeometry(geom)
neumannMarkers = []
robinMarkers = [ENDOCARD, BASE, EPICARD]

# Problem setting
Markers = MarkersSolid(markers, neumannMarkers, robinMarkers)
PhysicalParams = PhysicalParametersSolid(dt=1e-2, t0=0.0, sim_time=0.02, ys_degree=degree, AS=stress)
OutputParams = OutputParameters(name=name, verbose=True, export_solutions=export)
ts = Constant((0, 0, 0))


MS = MechanicsSolver(name)
MS.setup(mesh, PhysicalParams, Markers, OutputParams)
# Fibers
f0, s0, n0 = generateFibers(mesh, markers, ENDOCARD, EPICARD, BASE)
MS.setFibers(f0, s0, n0)
if MPI.rank(MPI.comm_world) == 0:
    print("Dofs =", MS.V.dim())
for i in range(1, PhysicalParams.Niter):
    t = PhysicalParams.t0 + i*PhysicalParams.dt
    if MPI.rank(MPI.comm_world) == 0:
        print("--- Solving time t={}".format(t), flush=True)
    current_t = time()

    MS.solveTimeStep(t, method=method, anderson_depth=0, LBFGS_order=LBFGS_order)

    if MPI.rank(MPI.comm_world) == 0:
        print("--- Solver in {} s".format(time() - current_t), flush=True)

    if export:
        MS.exportSolution(t)
