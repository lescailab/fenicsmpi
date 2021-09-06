#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Feb 22 14:06:24 2019

@author: barnafi
"""

def generate_boundary_measure(mesh, markers, tags_list, none_tag=42):
    from dolfin import Measure

    ds = Measure('ds', domain=mesh, subdomain_data=markers,
                 metadata={'optimize': True})
    return sum([ds(i) for i in tags_list], ds(none_tag))


def prolateGeometry(filename="prolate_4mm"):

    from dolfin import XDMFFile, Mesh, MeshValueCollection, MeshTransformation
    xdmf_meshfile = filename + ".xdmf"
    xdmf_meshfile_bm = filename + "_bm.xdmf"
    mesh = Mesh()
    with XDMFFile(xdmf_meshfile) as infile:
        infile.read(mesh)
    mvc = MeshValueCollection("size_t", mesh, 2)
    with XDMFFile(xdmf_meshfile_bm) as infile:
        infile.read(mvc, "name_to_read")
    from dolfin import cpp
    markers = cpp.mesh.MeshFunctionSizet(mesh, mvc)

    ENDOCARD = 20
    EPICARD = 10
    BASE = 50
    NONE = 99

    MeshTransformation.scale(mesh, 1e-3)
    return mesh, markers, ENDOCARD, EPICARD, BASE, NONE

