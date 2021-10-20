
# A nextflow workflow for preprocessing fastq files with fastp

# fastp
A tool designed to provide fast all-in-one preprocessing for FastQ files. This tool is developed in C++ with multithreading supported to afford high performance.
https://github.com/OpenGene/fastp.git

## Installation

### Nextflow
Install `nextflow` following the [instructions](https://www.nextflow.io/docs/latest/getstarted.html).

Be sure to run at least Nextflow version 21.04.3.

### Singularity
Install `singularity` following the instructions at
https://singularity.lbl.gov/install-linux

### fastp-nf pipeline

The most convenient way is to install `fastp-nf` is to use `nextflow`'s built-in `pull` command
```bash
nextflow pull xmzhuo/fastp-nf
```

## Documentation

* fastp: A tool designed to provide fast all-in-one preprocessing for FastQ files. This tool is developed in C++ with multithreading supported to afford high performance.

```bash
nextflow run xmzhuo/fastp-nf --help
```

## Credits
[Nextflow](https://github.com/nextflow-io/nextflow):  Paolo Di Tommaso

[Singularity](https://singularity.lbl.gov): Singularityware

[fastp](https://github.com/OpenGene/fastp.git): Shifu Chen Lab
