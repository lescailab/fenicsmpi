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
        container "library://nibscles/default/unipv:sha256.8ed337c4b43ff3e1546d05d5f08a6ee20c86670a38fde017ea2eaae5517fd"
    } else {
        container "quay.io/fenicsproject/stable:latest"
    }

    input:
    tuple val(meta), path(bam)

    output:
    // TODO nf-core: Named file extensions MUST be emitted for ALL output channels
    tuple val(meta), path("*.bam"), emit: bam

    script:
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"

    // module load will only work in environments with modules installed
    // and where the same module is present --> NOT portable

    """
    module load mpich

    mpirun -np $task.cpus python3 ${moduleDir}/Mechanics.py
    """
}
