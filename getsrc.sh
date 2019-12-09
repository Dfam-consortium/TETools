#!/bin/sh

set -eu

# download src name
download() {
  src="$1"
  shift

  if [ $# -ge 1 ]; then
    name="$1"
  else
    name="${src##*/}"
  fi

  dest="src/$name"

  if [ -n "${ALWAYS-}" ] || ! [ -f "$dest" ]; then
    echo "Downloading $src to $dest"
    curl -sSL "$src" > "$dest"
  fi
}

mkdir -p src

download http://www.repeatmasker.org/rmblast-2.9.0+-p2-x64-linux.tar.gz
download http://eddylab.org/software/hmmer/hmmer-3.2.1.tar.gz
download http://www.repeatmasker.org/RepeatScout-1.0.6.tar.gz
download http://www.repeatmasker.org/RepeatModeler/RECON-1.08.tar.gz
download https://github.com/weizhongli/cdhit/releases/download/V4.8.1/cd-hit-v4.8.1-2019-0228.tar.gz
download https://github.com/genometools/genometools/archive/v1.5.10.tar.gz gt-1.5.10.tar.gz
download https://github.com/oushujun/LTR_retriever/archive/v2.8.tar.gz LTR_retriever-2.8.tar.gz
download https://mafft.cbrc.jp/alignment/software/mafft-7.429-without-extensions-src.tgz
download https://github.com/TravisWheelerLab/NINJA/archive/0.97-cluster_only.tar.gz NINJA-cluster.tar.gz
download http://www.repeatmasker.org/coseg-0.2.2.tar.gz
download http://www.repeatmasker.org/RepeatMasker-4.1.0.tar.gz
download https://github.com/Dfam-consortium/RepeatModeler/archive/2.0.tar.gz RepeatModeler-2.0.tar.gz
