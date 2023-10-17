#!/bin/bash

declare -A installation_tests=(
    ["rmblast"]='/opt/rmblast/bin/rmblastn'
    ["hmmr"]='/opt/hmmer/bin/nhmmer' 
    ["trf"]='/opt/trf'
    ["repeat_scout"]='/opt/RepeatScout/RepeatScout'
    ["recon"]='/opt/RECON/bin/famdef'
    ["cd-hit"]='/opt/cd-hit/cd-hit'
    ["genometools"]='/opt/genometools/bin/gt'
    ["mafft"]='/opt/mafft/libexec/mafft/mafft-distance'
    ["ninja"]='/opt/NINJA/NINJA/Ninja'
    ["faToTwoBit"]='/opt/ucsc_tools/faToTwoBit'
    ["twoBitInfo"]='/opt/ucsc_tools/twoBitInfo'
    ["twoBitToFa"]='/opt/ucsc_tools/twoBitToFa'
    ["coseg"]='/opt/coseg/coseg'
)

run_installation_test () {
    test="$1"
    if ldd "${installation_tests[$test]}" | grep -q 'not found'
    then
        echo " - $test ERROR"
    else
        echo " - $test is installed correctly"
    fi
}

echo 'Running Installation Tests'
for test in "${!installation_tests[@]}"; do run_installation_test $test; done

# TODO - test outputs of installed programs
# declare -A functional_tests=(
#     ["rmblast"]='placeholder'
#     ["hmmr"]='placeholder' 
#     ["trf"]='placeholder'
#     ["repeat_scout"]='placeholder'
#     ["recon"]='placeholder'
#     ["cd-hit"]='placeholder'
#     ["genometools"]='placeholder'
#     ["ltr_retriever"]='placeholder'
#     ["mafft"]='placeholder'
#     ["ninja"]='placeholder'
#     ["faToTwoBit"]='placeholder'
#     ["twoBitInfo"]='placeholder'
#     ["twoBitToFa"]='placeholder'
#     ["coseg"]='placeholder'
#     ["repeatmasker"]='placeholder'
#     ["repeatmodeler"]='placeholder'
# )
# run_functional_test () {
#     test="$1"
#     if placeholder
#     then
#         echo "$test" "error"
#     else
#         echo "$test" "is working"
#     fi
# }
# echo 'Running Functional Tests'
# for test in "${!functional_tests[@]}"; do run_functional_test $test; done