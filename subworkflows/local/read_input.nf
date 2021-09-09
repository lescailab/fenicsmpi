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
    instances = inputSample // input now has a name as well, instead of keeping a separate meta. // channel: [ val(meta), val(inputs) ]

}



// Function to get list of [ meta, [ fastq_1, fastq_2 ] ]
// Note to self: If CSV headers include commas as "DEGREE", then Groovy requires doesnt read them well for some reason... 
// keep the CSV clean. 
def readInputFile(csvFile) {
    Channel.from(csvFile)
        .splitCsv(header:true, sep: ',')
        .map { row ->
            def inputs = [:]
            inputs.name = row.METHOD[0] + "-" + row.DEGREE + "-" + row.CORES + "-" + row.STRESS
            inputs.degree = row.DEGREE
            if (row.N) {
                inputs.n = row.N
            }
            if (row.STRESS) {
            inputs.stress = row.STRESS
            }
            inputs.method = row.METHOD
	    inputs.cores  = row.CORES
            return inputs
        }
}
