#!/bin/bash

cd videos

mv 2018-11-07a-299815101.mp4 nauru-a.mp4mv 2018-11-07b-299374582.mp4 nauru-b.mp4mv 2018-11-13-300592675.mp4 Rinehart-a.mp4mv 2018-11-14a-300675578.mp4 Rinehart-b.mp4mv 2018-11-14b-300710411.mp4 Parkes.mp4 mv 2018-12-07-304963408.mp4 McKell.mp4mv 2019-02-14-317155140.mp4 OKS.mp4


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








