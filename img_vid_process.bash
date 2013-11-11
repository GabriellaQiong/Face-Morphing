#!/bin/bash
# Script to process the headshots and videos
# Written by Qiong Wang, at University of Pennsylvania
# 11/11/2013

############## Modification part ################

# File Preporcessing Parameters
export SORT=0                           # Whether to sort files
export IMG_NUM=27                       # Number of images

# Video Merge and Audio Add Parameters
export MERGE=0                          # Whether to merge videos
export SLIDE=1                          # Whether to add slides
export AUDIO=0                          # Whether to add audio
export RATE=0.2                         # Sample fps
export DURATION=150                     # Sample length
export EXTENSION=avi                    # File extension format of video

# The directory contains camera# subfolders
export FILE_PATH="/home/qiong/Dropbox/Ubuntu/DPIM83/Face-Morphing"
export IMGS_FILE=$FILE_PATH/headshots/headshots.txt
export VIDS_FILE=$FILE_PATH/videos/videos.txt
export MERGE_FILE=$FILE_PATH/videos/merge.txt
export SLIDE_FILE=$FILE_PATH/music_photos/slides.txt
export AUDIO_FILE=$FILE_PATH/music_photos/california.mp3

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

# Merge videos
if [ "$MERGE" = 1 ]
then
    rm $MERGE_FILE
    ls $FILE_PATH/videos/*.avi > $VIDS_FILE
    while read line
    do
        echo "file '$line'" >> $MERGE_FILE
    done < $VIDS_FILE
    ffmpeg -f concat -i $MERGE_FILE -vcodec copy -acodec copy $FILE_PATH/merge.$EXTENSION
fi

# Add image slides
if [ "$SLIDE" = 1 ]
then
    ls $FILE_PATH/music_photos/*.jpg > $SLIDE_FILE
    count=0
    while read line
    do
        let "++count"
        Count=$(printf "%02d" $count)
        mv $line $FILE_PATH/music_photos/$Count.jpg
    done < $SLIDE_FILE
    ffmpeg -f image2 -r 1/5 -i $FILE_PATH/music_photos/%02d.jpg $FILE_PATH/music_photos/slide.mp4
    rm vid.txt
    echo "file '$FILE_PATH/music_photos/slide.mp4'" >> vid.txt
    echo "file '$FILE_PATH/merge.$EXTENSION'" >> vid.txt
    ffmpeg -r 30 -f concat -i vid.txt -vcodec copy -acodec copy $FILE_PATH/video.mp4
    #ffmpeg -i $FILE_PATH/music_photos/slide.$EXTENSION -i $FILE_PATH/merge.$EXTENSION -vcodec copy -acodec copy $FILE_PATH/video.$EXTENSION
fi

# Add audio
if [ "$AUDIO" = 1 ]
then

    ffmpeg -i $FILE_PATH/video.$EXTENSION -i $AUDIO_FILE -map 0 -map 1 -codec copy -shortest $FILE_PATH/boysday.$EXTENSION
fi

:<< '--COMMENT--'
HAPPY BOYS' DAY!!!!!
--COMMENT--
