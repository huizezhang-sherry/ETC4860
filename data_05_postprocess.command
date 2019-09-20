#!/bin/bash

mkdir data
cd data

cat ../list.txt | xargs mkdir

for f in *;
  do file=$(find ../csv/processed -type f -name "$f*")
  cp $file ../data/$f/;
done;

