#!/bin/bash
echo "Enter a sentence:"
read sentence
words=($sentence)
len=${#words[@]}
reversed=""
for((i=$len-1; i>=0; i--)); do
    reversed="$reversed ${words[$i]}"  
done
echo "Reversed sentence:$reversed"