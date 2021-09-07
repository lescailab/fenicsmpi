// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process FENICS_COMPUTE {
    tag "$meta.id"
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
    tuple val(meta), val(inputs)

    output:
    //tuple val(meta), path("./images/*/*.h5"), emit: image  // Not used
    tuple val(meta), path("${params.outdir}/*.xdmf"), emit: xdmf
    tuple val(meta), val(inputs), path("${meta.id}.out"), emit: stdout

    script:
    //def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    def prefix   = "${meta.id}"  // Simplify for now to be consistent with output

    // module load will only work in environments with modules installed
    // and where the same module is present --> NOT portable

    """
    mpirun -np $task.cpus python3 ${moduleDir}/Mechanics.py "${inputs.degree}" "${inputs.method}" "${inputs.stress}" "${params.mesh}" "${params.outdir}" &> ${prefix}.out
    """
}

process FENICS_PROCESS_OUTPUT {
    tag "$meta.id"
    label 'process_high'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    input:
    tuple val(meta), val(inputs), val(stdout)

    output:
    tuple val(meta), val(stdout-filtered-map), emit: stdout-filtered-map

    script:

    // First read stdout file and grep relevant lines 
    DOFS = ...
    // PASS

    // For all lines, count then sum to compute average
    SIZE = ...
    NL_ITS = ...
    TIME = ...


    stdout-filtered-map = [:]
    stdout-filtered-map.dofs = ...
    stdout-filtered-map.method = ...
    stdout-filtered-map.degree = ...
    stdout-filtered-map.cores = ...
    stdout-filtered-map.nonlinear_its = ...
    stdout-filtered-map.time = ...
}
