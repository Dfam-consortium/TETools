#!/bin/bash

PASS="  \033[0;32mPASS\033[0m"
FAIL="  \033[0;31mFAIL\033[0m"
docker_cmd="docker run -it --rm -v ./test_data:/opt/src/ dfam/tetools:dev"

declare -A installation_tests=(
    # Version or Help works
    ["RMBlast"]='/opt/rmblast/bin/rmblastn -version'
    ["HMMER"]='/opt/hmmer/bin/nhmmer -h' 
    ["genometools"]='/opt/genometools/bin/gt -version'
    ["NINJA"]='/opt/NINJA/Ninja -v'
    ["coseg"]='/opt/coseg/runcoseg.pl -version'
    ["RepeatMasker"]='/opt/RepeatMasker/RepeatMasker -v'
    ["FamDB"]='/opt/RepeatMasker/famdb.py -i ./Libraries/famdb info'
    ["RepeatModeler"]='/opt/RepeatModeler/RepeatModeler -version'
    # Needs actual input to test
    ["RepeatScout"]='/opt/RepeatScout/build_lmer_table -sequence example.fa -output out -freq 2'
    ["RECON"]='/opt/RECON/bin/imagespread /opt/src/seqnames /opt/src/elegans.msps 1'
    ["cd-hit"]='/opt/cd-hit/cd-hit -i example.fa -o out'
    ["MAFFT"]='/opt/mafft/bin/mafft /opt/src/example.fa'
    ["faToTwoBit"]='/opt/ucsc_tools/faToTwoBit /opt/src/example.fa out.fa.2bit'
    ["twoBitInfo"]='/opt/ucsc_tools/twoBitInfo /opt/src/example.fa.2bit out.tab'
    ["twoBitToFa"]='/opt/ucsc_tools/twoBitToFa /opt/src/example.fa.2bit out.fa'
)

echo 'Running Installation Tests'
echo 

for program in "${!installation_tests[@]}"; do 
    echo "Testing $program"
    $docker_cmd ${installation_tests[$program]} > /dev/null
    if [ $? -eq 0 ]; then
        echo -e $PASS
    else
        echo -e $FAIL
    fi
    echo
done

# TRF Never Returns 0
echo "Testing TRF"
outfile='./test_data/example.fa.2.7.7.80.10.50.4.dat'
rm -f "$outfile"
$docker_cmd /opt/trf /opt/src/example.fa 2 7 7 80 10 50 4 -h > /dev/null
if [ -s "$outfile" ]; then
    echo -e $PASS
else
    echo -e $FAIL
fi
echo

# LTR_retriever is large and complex and I don't know what it's doing
echo "Testing LTR_retriever"
tpases="./test_data/Tpases*"
alluniRef="./test_data/alluniRef*"
rm -f $tpases
rm -f $alluniRef

$docker_cmd /opt/LTR_retriever/LTR_retriever -genome /opt/src/example.fa > /dev/null

files_exist=false
for file in $tpases; do
    if [ -s "$file" ]; then
        files_exist=true
        break
    fi
done

if [ "$files_exist" = true ]; then
    echo -e $PASS
else
    echo -e $FAIL
fi
rm -f $tpases
rm -f $alluniRef
echo