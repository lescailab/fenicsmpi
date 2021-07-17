#!/usr/bin/env nextflow
/*
========================================================================================
    nf-core/fenicsmpi
========================================================================================
    Github : https://github.com/nf-core/fenicsmpi
    Website: https://nf-co.re/fenicsmpi
    Slack  : https://nfcore.slack.com/channels/fenicsmpi
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
========================================================================================
    GENOME PARAMETER VALUES
========================================================================================
*/

params.fasta = WorkflowMain.getGenomeAttribute(params, 'fasta')

/*
========================================================================================
    VALIDATE & PRINT PARAMETER SUMMARY
========================================================================================
*/

WorkflowMain.initialise(workflow, params, log)

/*
========================================================================================
    NAMED WORKFLOW FOR PIPELINE
========================================================================================
*/

include { FENICSMPI } from './workflows/fenicsmpi'

//
// WORKFLOW: Run main nf-core/fenicsmpi analysis pipeline
//
workflow NFCORE_FENICSMPI {
    FENICSMPI ()
}

/*
========================================================================================
    RUN ALL WORKFLOWS
========================================================================================
*/

//
// WORKFLOW: Execute a single named workflow for the pipeline
// See: https://github.com/nf-core/rnaseq/issues/619
//
workflow {
    NFCORE_FENICSMPI ()
}

/*
========================================================================================
    THE END
========================================================================================
*/
