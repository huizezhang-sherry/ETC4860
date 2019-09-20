#!/bin/bash

mkdir videos
cd videos

youtube-dl --batch-file=../download_list.txt --no-check-certificate
