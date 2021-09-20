// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process FENICS_REPORT {
    tag "$inputs.name"
    label 'process_low'
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
    val inputs
    path results
    //path xdmfs

    //output:

    script:
    def prefix = inputs.name
    //print(["INPUT", inputs])
    //print(["RESULT", results])


    """
    python ${moduleDir}/filter_csv.py "${results}"  "${projectDir}/results"
    """
}
