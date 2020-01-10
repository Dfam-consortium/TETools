# Dfam TE Tools container including RepeatMasker, RepeatModeler, coseg

FROM debian:9 AS builder

RUN apt-get -y update && apt-get -y install \
    curl gcc g++ make zlib1g-dev libgomp1 \
    perl \
    libfile-which-perl \
    libtext-soundex-perl \
    libjson-perl liburi-perl libwww-perl

COPY src/* /opt/src/
WORKDIR /opt/src

# Extract RMBlast
RUN echo 'e592d0601a98b9764dd55f2aa4815beb1987beb7222f0e171d4f4cd70a0d4a03  rmblast-2.10.0+-x64-linux.tar.gz' | sha256sum -c \
    && cd /opt \
    && mkdir rmblast \
    && tar --strip-components=1 -x -f src/rmblast-2.10.0+-x64-linux.tar.gz -C rmblast \
    && rm src/rmblast-2.10.0+-x64-linux.tar.gz

# Compile HMMER
RUN echo '0186bf40af67032666014971ed8ddc3cf2834bebc2be5b3bc0304a93e763736c  hmmer-3.3.tar.gz' | sha256sum -c \
    && tar -x -f hmmer-3.3.tar.gz \
    && cd hmmer-3.3 \
    && ./configure --prefix=/opt/hmmer && make && make install \
    && make clean

# Compile RepeatScout
RUN echo '31a44cf648d78356aec585ee5d3baf936d01eaba43aed382d9ac2d764e55b716  RepeatScout-1.0.6.tar.gz' | sha256sum -c \
    && tar -x -f RepeatScout-1.0.6.tar.gz \
    && cd RepeatScout-1.0.6 \
    && sed -i 's#^INSTDIR =.*#INSTDIR = /opt/RepeatScout#' Makefile \
    && make && make install

# Compile and configure RECON
RUN echo '699765fa49d18dbfac9f7a82ecd054464b468cb7521abe9c2bd8caccf08ee7d8  RECON-1.08.tar.gz' | sha256sum -c \
    && tar -x -f RECON-1.08.tar.gz \
    && mv RECON-1.08 ../RECON \
    && cd ../RECON \
    && make -C src && make -C src install \
    && cp 00README bin/ \
    && sed -i 's#^\$path =.*#$path = "/opt/RECON/bin";#' scripts/recon.pl

# Compile cd-hit
RUN echo '26172dba3040d1ae5c73ff0ac6c3be8c8e60cc49fc7379e434cdf9cb1e7415de  cd-hit-v4.8.1-2019-0228.tar.gz' | sha256sum -c \
    && tar -x -f cd-hit-v4.8.1-2019-0228.tar.gz \
    && cd cd-hit-v4.8.1-2019-0228 \
    && make && mkdir /opt/cd-hit && PREFIX=/opt/cd-hit make install

# Compile genometools (for ltrharvest)
RUN echo 'd59dbf5bc6151b40ec6e53abfb3fa9f50136a054448759278a8c862e288cd3c9  gt-1.6.0.tar.gz' | sha256sum -c \
    && tar -x -f gt-1.6.0.tar.gz \
    && cd genometools-1.6.0 \
    && make -j4 cairo=no && make cairo=no prefix=/opt/genometools install \
    && make cleanup

# Configure LTR_retriever
RUN echo '4e10c4df03cd84a841f90a0ac636a04863279b85ad6cfc155905e7ac29d46a8b  LTR_retriever-2.8.tar.gz' | sha256sum -c \
    && cd /opt \
    && tar -x -f src/LTR_retriever-2.8.tar.gz \
    && mv LTR_retriever-2.8 LTR_retriever \
    && cd LTR_retriever \
    && sh -c 'rm bin/trf*' \
    && ln -s /opt/trf bin/trf409.legacylinux64 \
    && sed -i \
        -e 's#BLAST+=#BLAST+=/opt/rmblast/bin#' \
        -e 's#RepeatMasker=#RepeatMasker=/opt/RepeatMasker#' \
        -e 's#HMMER=#HMMER=/opt/hmmer/bin#' \
        -e 's#CDHIT=#CDHIT=/opt/cd-hit#' \
        paths

# Compile MAFFT
RUN echo '4c05dfc4d173c9a139fcaa9373fbc2c8d6a59f410a7971f7acc6268be628b1f9  mafft-7.453-without-extensions-src.tgz' | sha256sum -c \
    && tar -x -f mafft-7.453-without-extensions-src.tgz \
    && cd mafft-7.453-without-extensions/core \
    && sed -i 's#^PREFIX =.*#PREFIX = /opt/mafft#' Makefile \
    && make clean && make && make install \
    && make clean

# Compile NINJA
RUN echo 'b9b948c698efc3838e63817f732ead35c08debe1c0ae36b5c74df7d26ca4c4b6  NINJA-cluster.tar.gz' | sha256sum -c \
    && cd /opt \
    && mkdir NINJA \
    && tar --strip-components=1 -x -f src/NINJA-cluster.tar.gz -C NINJA \
    && cd NINJA/NINJA \
    && make clean && make all

# Compile and configure coseg
RUN echo 'e666874cc602d6a03c45eb2f19dc53b2d95150c6aae83fea0842b7db1d157682  coseg-0.2.2.tar.gz' | sha256sum -c \
    && cd /opt \
    && tar -x -f src/coseg-0.2.2.tar.gz \
    && cd coseg \
    && sed -i 's#use lib "/usr/local/RepeatMasker";#use lib "/opt/RepeatMasker";#' preprocessAlignments.pl \
    && make

# Configure RepeatMasker
RUN echo '7370014c2a7bfd704f0e487cea82a42f05de100c40ea7cbb50f54e20226fe449  RepeatMasker-4.1.0.tar.gz' | sha256sum -c \
    && cd /opt \
    && tar -x -f src/RepeatMasker-4.1.0.tar.gz \
    && chmod a+w RepeatMasker/Libraries \
    && cd RepeatMasker \
    && ln -s /bin/true /opt/trf \
    && perl configure \
        -hmmer_dir=/opt/hmmer/bin \
        -rmblast_dir=/opt/rmblast/bin \
        -libdir=/opt/RepeatMasker/Libraries \
        -trf_prgm=/opt/trf \
        -default_search_engine=rmblast \
    && rm /opt/trf \
    && cd .. && rm src/RepeatMasker-4.1.0.tar.gz

# Configure RepeatModeler
RUN echo '628e7e1556865a86ed9d6a644c0c5487454c99fbcac21b68eae302fae7abb7ac  RepeatModeler-2.0.1.tar.gz' | sha256sum -c \
    && cd /opt \
    && tar -x -f src/RepeatModeler-2.0.1.tar.gz \
    && mv RepeatModeler-2.0.1 RepeatModeler \
    && cd RepeatModeler \
    && perl configure \
         -cdhit_dir=/opt/cd-hit -genometools_dir=/opt/genometools/bin \
         -ltr_retriever_dir=/opt/LTR_retriever -mafft_dir=/opt/mafft/bin \
         -ninja_dir=/opt/NINJA/NINJA -recon_dir=/opt/RECON/bin \
         -repeatmasker_dir=/opt/RepeatMasker \
         -rmblast_dir=/opt/rmblast/bin -rscout_dir=/opt/RepeatScout \
         -trf_prgm=/opt/trf

FROM debian:9

# Install dependencies and some basic utilities
RUN apt-get -y update \
    && apt-get -y install \
        aptitude \
        libgomp1 \
        perl \
        libfile-which-perl \
        libtext-soundex-perl \
        libjson-perl liburi-perl libwww-perl \
    && aptitude install -y ~pstandard ~prequired \
        curl wget \
        vim nano \
        libpam-systemd-

RUN echo "PS1='(dfam-tetools) \w\$ '" >> /etc/bash.bashrc
COPY --from=builder /opt /opt
ENV LANG=C
ENV PATH=/opt/RepeatMasker:/opt/RepeatMasker/util:/opt/RepeatModeler:/opt/RepeatModeler/util:/opt/coseg:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
