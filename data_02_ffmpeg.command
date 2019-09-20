#!/bin/bash

cd videos

mv 2018-11-07a-299815101.mp4 nauru-a.mp4


cd ../
mkdir dt
cd dt

cat ../list.txt | xargs mkdir

ffmpeg -i ../videos/nauru-a.mp4 -r 1/60 ../dt/Nauru-a/nauru-a_%3d.png
ffmpeg -i ../videos/nauru-b.mp4 -r 1/60 ../dt/Nauru-b/nauru-b_%3d.png
ffmpeg -i ../videos/OKS.mp4 -r 1/60 ../dt/OKS/OKS_%3d.png
ffmpeg -i ../videos/McKell.mp4 -r 1/60 ../dt/McKell/McKell_%3d.png
ffmpeg -i ../videos/Rinehart-a.mp4 -r 1/60 ../dt/Rinehart-a/Rinehart-a_%3d.png
ffmpeg -i ../videos/Rinehart-b.mp4 -r 1/60 ../dt/Rinehart-b/Rinehart-b_%3d.png
ffmpeg -i ../videos/Parkes.mp4 -r 1/60 ../dt/Parkes/Parkes_%3d.png

cd ../
mkdir cropped 
cd cropped 

cat ../list.txt | xargs mkdir

for dir in */; do mkdir -- "$dir"/1 "$dir"/2 "$dir"/3 "$dir"/4 "$dir"/5; done







