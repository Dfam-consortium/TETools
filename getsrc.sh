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

download http://www.repeatmasker.org/rmblast/rmblast-2.14.1+-x64-linux.tar.gz
# download http://www.repeatmasker.org/rmblast/rmblast-2.14.1+-arm64-macosx.tar.gz
download http://eddylab.org/software/hmmer/hmmer-3.4.tar.gz
download https://github.com/Benson-Genomics-Lab/TRF/archive/v4.09.1.tar.gz trf-4.09.1.tar.gz
download https://github.com/Dfam-consortium/RepeatScout/archive/refs/tags/v1.0.7.tar.gz RepeatScout-1.0.7.tar.gz
download http://www.repeatmasker.org/RECON-1.08.tar.gz
download https://github.com/weizhongli/cdhit/releases/download/V4.8.1/cd-hit-v4.8.1-2019-0228.tar.gz
download https://github.com/genometools/genometools/archive/v1.6.4.tar.gz gt-1.6.4.tar.gz
download https://github.com/oushujun/LTR_retriever/archive/v2.9.0.tar.gz LTR_retriever-2.9.0.tar.gz
download https://mafft.cbrc.jp/alignment/software/mafft-7.471-without-extensions-src.tgz
download https://github.com/TravisWheelerLab/NINJA/archive/1.00-cluster_only.tar.gz NINJA-cluster.tar.gz
# download https://www.repeatmasker.org/coseg-0.2.3.tar.gz
download https://github.com/rmhubley/coseg/archive/refs/tags/coseg-0.2.3.tar.gz
# download https://www.dfam.org/releases/Dfam_3.8/families/FamDB/dfam38_full.0.h5.gz
download https://www.dfam.org/releases/Dfam_3.8/families/Dfam-RepeatMasker.lib.gz
download http://www.repeatmasker.org/RepeatMasker/RepeatMasker-4.1.7-p1.tar.gz
download https://github.com/Dfam-consortium/RepeatModeler/archive/2.0.6.tar.gz RepeatModeler-2.0.6.tar.gz
# download https://github.com/zhangrengang/TEsorter/archive/v1.4.6.tar.gz TEsorter-1.4.6.tar.gz

# TODO: /exe/ only includes binaries of the "latest" version at the time of download.
# The version listed in README.md is obtained by running 'strings src/faToTwoBit | grep kent'
# On whatever was downloaded.
# Consider building these tools from source instead.
for tool in faToTwoBit twoBitInfo twoBitToFa; do
  download https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/"$tool"
done
#   mv src/"$tool" src/"$tool"_x86

#   download https://hgdownload.soe.ucsc.edu/admin/exe/macOSX.arm64/"$tool"
#   mv src/"$tool" src/"$tool"_arm64
# done

cd ./src
sha256sum -b * > sha256sums.txt
cd ..
cp ./src/sha256sums.txt sha256sums.txt
rm ./src/sha256sums.txt 
