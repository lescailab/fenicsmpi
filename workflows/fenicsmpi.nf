// Check mandatory parameters
if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input CSV file not specified!' }  // This could be eventually done here with combine... perhaps

if (params.mesh) { ch_mesh = file(params.mesh) } else { exit 1, 'Mesh file not specified! [full path required' }

if (params.outdir) { ch_outdir = file(params.outdir) } else { exit 1, 'Output directory not specified!' }

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
include { READ_INPUT } from '../subworkflows/local/read_input.nf' addParams( options: [:] )

/*
========================================================================================
    IMPORT LOCAL MODULES
========================================================================================
*/

// MODULE: Import local modules
//
include { FENICS_COMPUTE  } from '../modules/local/fenics/compute/main'  addParams( options: modules['fenics_compute'] )
include { FENICS_REPORT } from '../modules/local/fenics/report/main' addParams( options: modules['fenics_report']   )

/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/


workflow FENICSMPI {

    //
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    //
    READ_INPUT (
        ch_input
    )
    //READ_INPUT.out.inputSample.subscribe onNext: { println it.degree }, onComplete: { println 'Done' }

    //
    // MODULE: Run COMPUTE
    //
    FENICS_COMPUTE (
        READ_INPUT.out.inputSample
    )

    

      //
    // MODULE: Run REPORT
    //
    //FENICS_REPORT (
    //    FENICS_COMPUTE.out.xml
    //)



}


/*
========================================================================================
    THE END
========================================================================================
*/
