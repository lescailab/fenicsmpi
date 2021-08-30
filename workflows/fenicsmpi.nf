// Check mandatory parameters
if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }

/*
========================================================================================
    CONFIG FILES
========================================================================================
*/

/*
========================================================================================
    IMPORT LOCAL MODULES/SUBWORKFLOWS
========================================================================================
*/

// Don't overwrite global params.modules, create a copy instead and use that within the main script.
def modules = params.modules.clone()

/*
========================================================================================
    IMPORT LOCAL MODULES
========================================================================================
*/

// MODULE: Import local modules
//
include { FENICS_COMPUTE  } from '../modules/local/fenics/compute'  addParams( options: modules['fenics_compute'] )
include { FENICS_REPORT } from '../modules/local/fenics/report' addParams( options: modules['fenics_report']   )

/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/


workflow FENICSMPI {

    //
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    //
    INPUT_CHECK (
        ch_input
    )

    //
    // MODULE: Run COMPUTE
    //
    FENICS_COMPUTE (

    )


      //
    // MODULE: Run REPORT
    //
    FENICS_REPORT (

    )



}

/*
========================================================================================
    COMPLETION EMAIL AND SUMMARY
========================================================================================
*/

workflow.onComplete {
    NfcoreTemplate.summary(workflow, params, log)
}

/*
========================================================================================
    THE END
========================================================================================
*/
