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
    inputSample // channel: [ val(meta), val(inputs) ]

}



// Function to get list of [ meta, [ fastq_1, fastq_2 ] ]
def readInputFile(csvFile) {
    Channel.from(tsvFile)
        .splitCsv(header:true, sep: ',')
        .map { row ->
            def meta = [:]
            def inputs = [:]
            def array = []
            meta.id = row.ID
            inputs.degree = row.DEGREE
            if (row.N) {
                inputs.n = row.N
            }
            if (row.STRESS) {
                inputs.stress = row.STRESS
            }
            inputs.methods = row.METHOD
            array = [ meta, inputs ]
            return array
        }
}
