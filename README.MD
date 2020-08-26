# Kraken2 Pipeline in Nextflow

This pipeline maps the taxonomy of paired fastq files using kraken2. It combines all the output files and converts it into a single biom file. Then the biom file is converted into a tsv.

### Dependencies:
1. [Nextflow](https://www.nextflow.io/)
2. [Singularity](https://sylabs.io/docs/) - if you are running this on a cluster, please install version 3.6 or later. 
3. A reference [kraken2 library] (https://ccb.jhu.edu/software/kraken2/index.shtml?t=downloads). By default, it will look for `$baseDir/db/minikraken2_v2_8GB_201904_UPDATE`

### Usage: 
Test the full pipeline with prepackaged data:
```
nextflow run kraken2_biom/main.nf 
```

Use the configuration file to run on the SGE system in SCBS with log tracing 
```
nextflow run kraken2_biom/main.nf -c quaisar_nf/cdc_sge.config -with-report report.html
```

