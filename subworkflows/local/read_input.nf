//
// get input channel
//

params.options = [:]

workflow READ_INPUT {

    take:
    inputCsv

    main:
    inputSample = Channel.empty()
    inputSample = readInputFile(inputCsv)

    emit:
    inputSample // channel: [ val(meta), val(inputs) ]... not for now, using only a map with DEGREE, STRESS, METHOD, CORES.

}



// Function to get list of [ meta, [ fastq_1, fastq_2 ] ]
// Note to self: If CSV headers include commas as "DEGREE", then Groovy requires doesnt read them well for some reason... 
// keep the CSV clean. 
def readInputFile(csvFile) {
    Channel.from(csvFile)
        .splitCsv(header:true, sep: ',')
        .map { row ->
            def meta = [:]
            def inputs = [:]
            def array = []
            meta.id = row.METHOD[0] + "-" + row.DEGREE + "-" + row.CORES + "-" + row.STRESS
            meta.run = "none"
            inputs.degree = row.DEGREE
            if (row.N) {
                inputs.n = row.N
            }
            if (row.STRESS) {
            inputs.stress = row.STRESS
            }
            inputs.method = row.METHOD
	    inputs.cores  = row.CORES
            array = [ meta, inputs ]
            return array
        }
}
