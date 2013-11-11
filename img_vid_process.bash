#!/bin/bash
# Script to process the headshots and videos
# Written by Qiong Wang, at University of Pennsylvania
# 11/10/2013

############## Modification part ################

# File Preporcessing Parameters
export SORT=1                           # Whether to sort files
export IMG_NUM=27                       # Number of images

# Video Merge and Audio Add Parameters
export MERGE=0                          # Whether to merge videos
export AUDIO=0                          # Whether to add audio
export RATE=0.1                         # Sample fps
export DURATION=150                     # Sample length
export EXTENSION=AVI                    # File extension format of video

# The directory contains camera# subfolders
export FILE_PATH="/home/qiong/Dropbox/Ubuntu/DPIM83/Face-Morphing"
export IMGS_FILE=$FILE_PATH/headshots/headshots.txt
export VIDS_FILE=$FILE_PATH/videos.txt

############## Modification end #################

# Preprocess the images
if [ "$SORT" = 1 ]
then
    cd $FILE_PATH/headshots
    ls *.jpg > headshots.txt
    cd ..
    count=0
    while read line
    do
        let "++count"
        echo "Processing image $count ..."
        Count=$(printf "%02d" $count)
        mv $FILE_PATH/headshots/$line $FILE_PATH/headshots/$Count.jpg
    done < $IMGS_FILE
fi

:<< '--COMMENT--'
# Extract images from video for rectification
if [ "$MERGE" = 1 ]
then
    for ((n=1;n<=$N;++n)) 
    do
        m=$(printf "%02d" $n)
        rm -rf $GOPRO_PATH/camera$m/images_raw$m
        mkdir $GOPRO_PATH/camera$m/images_raw$m
        count=0
        for ((i=1;i<=$VID_NUM;++i))
        do
            j=$(printf "%03d" $i)
            echo "Processing video $j for camera$m..."
            if [ $i -eq 24 -o $i -eq 26 ]
            then
                rm -rf temp.txt
                if [ $i -eq 24 ]
                then
#                    export RATE=0.1
                    ffmpeg -ss 00:00:10 -t $DURATION -i "$GOPRO_PATH/camera$m/video_raw$m/camera$m""_video$j.MP4" -f image2 -r $RATE "$GOPRO_PATH/camera$m/images_raw$m/temp_""%05d.$EXTENSION"
                else
                    export RATE=0.2
                    ffmpeg -ss 00:00:10 -i "$GOPRO_PATH/camera$m/video_raw$m/camera$m""_video$j.MP4" -f image2 -r $RATE "$GOPRO_PATH/camera$m/images_raw$m/temp_""%05d.$EXTENSION"
                fi
                cd $GOPRO_PATH/camera$m/images_raw$m
                ls temp*.$EXTENSION > temp.txt
                cd ../..
                while read line
                do
                    let "++count"
                    echo "Processing video $count for camera$m..."
                    echo "file is $line"
                    Count=$(printf "%05d" $count)
                    mv $GOPRO_PATH/camera$m/images_raw$m/$line "$GOPRO_PATH/camera$m/images_raw$m/camera$m""_$Count.$EXTENSION"
                done < $GOPRO_PATH/camera$m/images_raw$m/temp.txt
            else
                let "++count"
                Count=$(printf "%05d" $count)
                ffmpeg -ss 00:00:00.500 -t 1 -i "$GOPRO_PATH/camera$m/video_raw$m/camera$m""_video$j.MP4" -f image2 -r 1 "$GOPRO_PATH/camera$m/images_raw$m/camera$m""_$Count.$EXTENSION"
            fi
        done
  done
fi

mkdir $GOPRO_PATH/raw
for ((n=1;n<=$N;++n))
do 
    m=$(printf "%02d" $n)
    cp $GOPRO_PATH/camera$m/images_raw$m/*.$EXTENSION $GOPRO_PATH/raw/
done

rm -rf $GOPRO_PATH/raw_keyframes
mkdir $GOPRO_PATH/raw_keyframes
while read line
do
    echo "Processing image""_00$line.$EXTENSION..."  
    cp $GOPRO_PATH/raw/*_00$line.$EXTENSION $GOPRO_PATH/raw_keyframes/
done < $KEYFRAME_FILE
--COMMENT--
