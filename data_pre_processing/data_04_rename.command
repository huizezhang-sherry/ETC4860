#!/bin/bash



j=(1 2 3 4 5)
echo ${j[@]}

f=(nauru-a nauru-b McKell OKS Parkes Rinehart-a Rinehart-b)
echo ${f[@]}

for judge in ${j[@]}
do
  for folder in ${f[@]}
  do 
  cd ./cropped/$folder/$judge
    for image in *.png 
    do 
      mv "$image" "$judge-$image"
    done
    cd ../../../
  done
done