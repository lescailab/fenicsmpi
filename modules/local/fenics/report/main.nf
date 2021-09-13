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
    //tuple val(meta), path(xml)
    val inputs
    path results
    //path xdmfs

    //output:
    //path("*csv"), emit: report
    //tuple val(meta), path("*.RData"), emit: analysis

    script:
    //def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    def prefix = inputs.name
    print(["INPUT", inputs])
    print(["RESULT", results])

    // We iterate over results. 
    // For scalability: Keep TIME vs CORES for all methods, degrees for stress=1e4.
    // For robustness: Keep NL_ITS vs CORES (stress=1e4)  and NL_ITS vs STRESS (cores=16), for all methods, degrees.

    // Scalability
    // scalab_items = [:]  // First get relevant items to sort them out
    // for (i in 0..inputs.size()-1)
    // {
    //     if (inputs[i].stress == "1e4")
    //     {
    //         def tag = inputs[i].name[0] + inputs[i].degree
    //         def filename = results[i]
    //         def res = new File(filename)
    //         time = res.text.split(',').last()
    //         if (scalab_items.containsKey(tag))
    //         {
    //     	scalab_items[tag].add([inputs[i].cores,time])
    //         }
    //         else
    //         {
    //             scalab_items[tag] = []
    //     	scalab_items[tag].add([inputs[i].cores,time])
    //         }
    //     }
    // }
    // println(scalab_items)
    //         //def outfile = new File('scalab_' + inputs[i].method[0] + '-' + inputs[i].degree '.csv')
    //         //outfile.write("cores,time\n")
    //         //scalab_items.add([inputs[i].name,inputs[i].cores,results[i]])
    // println(scalab_items)

    """
    python ${moduleDir}/filter_csv.py "${results}"  "${projectDir}/results"
    """
}
