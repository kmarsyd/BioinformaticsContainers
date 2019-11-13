#Dockerfile to install an GATK and a bunch of other bioinformatics tools
#If you make use of this image, please acknowledge 
#Sydney Informatics Hub at the University of Sydney
#https://informatics.sydney.edu.au/


#build with root privledges `sudo -i` as sudo was not used in Dockerfile

#Build usage:
#sudo docker build . -t fastq_to_vcf

#Run with something like:
#sudo docker run --rm -it -v `pwd`:/workspace fastq_to_vcf


#Start with the broadinstitute docker file which contains samtools 1.19 and JAVA 1.8.0
FROM broadinstitute/gatk:4.1.2.0

LABEL maintainer="kristian.maras@sydney.edu.au"

#Create a workspace
WORKDIR /opt

#Make workspaces that are used for data storage at runtime
RUN mkdir /project /projects #for mounting Usyd HPC and NCI 
RUN mkdir /scratch /shared   #other possible mountings 

#Now install everything else we need


RUN apt-get update  # Ensure the package list is up to date
RUN yes | apt-get install autoconf automake make gcc g++ perl zlib1g-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev libssl-dev libncurses5-dev



#samtools 1.9 specifically - includes htslib
RUN wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2
RUN tar -xf samtools-1.9.tar.bz2 && \
	cd samtools-1.9/ && \
	./configure && \
	make && \
	make install

#samblaster 

RUN wget https://github.com/GregoryFaust/samblaster/releases/download/v.0.1.24/samblaster-v.0.1.24.tar.gz
RUN tar -xf samblaster-v.0.1.24.tar.gz && \
	cd samblaster-v.0.1.24/ && \
	make && \ 
	cp samblaster /usr/local/bin/.  

#Tabix added
RUN yes | apt-get install git-all
RUN git clone https://github.com/samtools/tabix.git
RUN cd tabix && \ 
	make && \
	cp tabix /usr/local/bin/.


#sambamba
RUN wget https://github.com/biod/sambamba/releases/download/v0.7.0/sambamba-0.7.0-linux-static.gz
RUN gzip -d sambamba-0.7.0-linux-static.gz && \
    chmod 755 sambamba-0.7.0-linux-static && \
    cp sambamba-0.7.0-linux-static /usr/local/bin/sambamba

#fastp
RUN wget https://github.com/OpenGene/fastp/archive/v0.20.0.tar.gz
RUN tar -xzf v0.20.0.tar.gz && \
	cd fastp-0.20.0 && \
	make && \
	make install && \
	cd ..

#bwa
RUN wget https://github.com/lh3/bwa/releases/download/v0.7.15/bwakit-0.7.15_x64-linux.tar.bz2
RUN tar -xjf bwakit-0.7.15_x64-linux.tar.bz2 && \
	cp bwa.kit/bwa /usr/local/bin/bwa

#Make somewhere to work and test our applications
WORKDIR /workspace

CMD /bin/bash
