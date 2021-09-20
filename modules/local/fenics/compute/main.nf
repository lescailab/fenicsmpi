// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process FENICS_COMPUTE {
    tag "${inputs.name}"
    label 'process_high'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "conda-forge::fenics" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "library://nibscles/default/unipv:fenicsproject"
    } else {
        container "quay.io/fenicsproject/stable:latest"
    }

    //module 'mpich'

    input:
    val(inputs)

    output:
    //tuple val(meta), path("./images/*/*.h5"), emit: image  // Not used
    path("${params.outdir}/*.xdmf"), emit: xdmf
    path("*.out"), emit: results

    script:
    def prefix   = "${inputs.name}"  // Simplify for now to be consistent with output

    """
    #!/bin/bash

    sh ${moduleDir}/simulate_and_clean.sh ${inputs.cores} ${moduleDir} ${inputs.degree} ${inputs.method} ${inputs.stress} ${params.mesh} ${params.outdir} ${prefix}.out
    """
    
//    """
//    OUTFILE=${prefix}.out
//    mpirun -np ${inputs.cores} python3 ${moduleDir}/Mechanics.py "${inputs.degree}" "${inputs.method}" "${inputs.stress}" "${params.mesh}" "${params.outdir}" > TEMP
//
//    //DOFS=\$(grep 'Dofs' TEMP | sed -E 's/.*Dofs = ([0-9]+).*/\1/g')
//    //grep 'nonlinear' TEMP | sed -E 's/.*in ([0-9]+) nonlinear.*/\1/g' > NL_ITS
//    //grep 'nonlinear' TEMP | sed -E 's/.* ([0-9]+\.[0-9]+)s.*/\1/g' > TIMES
//    //NL_IT=\$(python3 ${moduleDir}/column_average.py NL_ITS)
//    //TIME=\$(python3 ${moduleDir}/column_average.py TIMES)
//    //echo \$DOFS,\$NL_IT,\$TIME > \$OUTFILE
//    //rm TEMP DOFS NL_ITS TIMES
//    """


}

