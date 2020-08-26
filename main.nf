#!/usr/bin/env nextflow


Channel.fromFilePairs( params.in ).into { fastq_files; fastq_files2 }
kraken_db = file(params.kraken_db)


println """\
         K R A K E N     NEXTFLOW      PIPELINE   
         =====================================================
         input reads (--in)                  : ${params.in}
         outdir (--out)                      : ${params.out}
         Kraken Database (--kraken_db)       : ${params.kraken_db}

         """
         .stripIndent()


process fastqc {
    
    //errorStrategy 'ignore'
    publishDir params.out, pattern: "*.html", mode: 'copy', overwrite: true

    input:
    set val(name), file(fastq) from fastq_files
 
    output:
    file "*_fastqc.{zip,html}" into qc_files, qc_files1

    """
    fastqc -q ${fastq}
    """
}

process multiqc {

    //errorStrategy 'ignore'
    publishDir params.out, mode: 'copy', overwrite: true

    input:
    file reports from qc_files.collect().ifEmpty([])

    output:
    path "multiqc_report.html" into multiqc_output

    """
    multiqc $reports
    """
}


process kraken_fastq {

    //errorStrategy 'ignore'
    publishDir params.out, mode: 'copy', overwrite: true
    memory '8 GB'

    input:
    tuple val(name), file(fastq) from fastq_files2

    output:
    file("*.summary") into kraken_fastq_out

    """
    kraken2 --db ${kraken_db} --paired ${fastq} --memory-mapping --report ${name}_reads.summary --output ${name}_reads.output
    """
}

process kraken_biom {

    //errorStrategy 'ignore'
    publishDir params.out, mode: 'copy', overwrite: true

    input:
    file(kraken_result) from kraken_fastq_out.collect()

    output:
    path "taxonomy_table.biom" into kraken_biom_output

    """
    kraken-biom ${kraken_result} -o taxonomy_table.biom --max D --min S
    """
}

process biom_convert {

    //errorStrategy 'ignore'
    publishDir params.out, mode: 'copy', overwrite: true

    input:
    file(tax_table) from kraken_biom_output

    output:
    path "taxonomy_table.tsv" into biom_convert_output

    """
    biom convert -i ${tax_table} -o taxonomy_table.tsv --to-tsv --header-key taxonomy
    """
}
