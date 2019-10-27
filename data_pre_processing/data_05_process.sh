#!/bin/bash

# docker run -it --rm algebr/openface:latest
# id=$(docker ps -aq)
# echo $id
# docker cp ./cropped $id:/home/openface-build/ 
# docker cp process.sh $id:/home/openface-build/
# chmod +x process.sh
# ./process.sh

videos=$(find ./cropped/ -mindepth 2 -type "d" )

echo $videos

for f in $videos;
  do mkdir ../processed/$video
  build/bin/FaceLandmarkImg -fdir $f;
done;

# docker exec $id:/home/openface-build process.sh (not really this line)

# docker cp $id:/home/openface-build/processed/ ./csv
