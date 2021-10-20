#!/usr/bin/env nextflow

/*
* MIT License
*
* Copyright (c) 2021 Xinming Zhuo
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

nextflow.enable.dsl=2

def helpMessage() {
    log.info"""
    ================================================================
    fastp-nf
    ================================================================
    DESCRIPTION
    Usage:
    nextflow run xmzhuo/fastp-nf

    Options:
        --inputDir        	Input directory of fastq files.
        --outputDir        	Output folder for fastp output files.
	--advanceArg            Advance argument for fastp. ie: --umi --umi_loc=read1 --umi_len=8 --trim_poly_g

    Profiles:
        standard            local execution
        slurm               SLURM execution with singularity on HPC
        azure               batch execution with Docker on Azure

    Docker:
    xmzhuo/fastp:0.23.0

    Author:
    Xinming Zhuo (zhuoxn@jax.org)
    """.stripIndent()
}

params.help = false

if (params.help) {
    helpMessage()
    exit 0
}

params.inputDir = "$baseDir/testdata"
params.outputDir = 'results'
params.advanceArg = ''

log.info """\
    parameters 
    ======================
    input directory          : ${params.inputDir}
    output directory         : ${params.outputDir}
    advanced arguments       : ${params.advanceArg}
    ======================
    """
    .stripIndent()


process fastp {
    
    publishDir params.outputDir, mode: 'copy' 
	tag "fastp processing: $lane"

    input:
    tuple val(lane), file(reads) 
    val advarg 

    output:
    path "${lane}_*{html,json,fq}*"

    shell:

    def single = reads instanceof Path

    if (!single)

      '''
      fastp -i !{reads[0]} -I !{reads[1]} \
        -o !{lane}_out.R1.fq.gz -O !{lane}_out.R2.fq.gz \
        --unpaired1 !{lane}_out.R1.unpaired.fq.gz --unpaired2 !{lane}_out.R2.unpaired.fq.gz \
        -j !{lane}_fastp.json -h !{lane}_fastp.html -R !{lane}_fastp \
        !{advarg}
	  '''
    else
      '''
      fastp -i !{reads} -o !{lane}_out.fq.gz \
        -j !{lane}_fastp.json -h !{lane}_fastp.html -R !{lane}_fastp \
        !{advarg}
	  '''

}

workflow {
    /*
    * Create the `fastqChannel` channel that emits tuples containing three elements:
    * the pair ID, the first read-pair file and the second read-pair file 
    */
    pairedEndRegex = params.inputDir + "/*{1,2}.fq*"
    SERegex = params.inputDir + "/*[!12].fq*"

    pairFiles = Channel.fromFilePairs(pairedEndRegex)
    singleFiles = Channel.fromFilePairs(SERegex, size: 1){ file -> file.baseName.replaceAll(/.fq/,"") }  

    fastqChannel = singleFiles.mix(pairFiles)  
    
    fastqChannel.view()
    
    fastp(fastqChannel, params.advanceArg)
    
}

workflow.onComplete {
   
    log.info """\
        xmzhuo/fastp-nf has finished.
        Status:   ${workflow.success ? "SUCCESS" : "ERROR"}
        Time:     ${workflow.complete}
        Duration: ${workflow.duration}\n
        """
        .stripIndent()
}
