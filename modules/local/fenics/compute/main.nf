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

    input:
    tuple val(meta), val(inputs)

    output:
    tuple val(meta), path("/images/*/*.h5"), emit: image
    tuple val(meta), path("/images/*/*.xdmf"), emit: xml

    script:
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"

    // module load will only work in environments with modules installed
    // and where the same module is present --> NOT portable

    """
    module load mpich

    mpirun -np $task.cpus python3 ${moduleDir}/Mechanics.py "${inputs.degree}" "${inputs.method}" "${inputs.stress}"
    """
}
