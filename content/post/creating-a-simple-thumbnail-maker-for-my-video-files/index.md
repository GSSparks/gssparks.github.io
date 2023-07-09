---
title: "Creating a Simple Thumbnail Maker for my Video Files"
date: 2022-09-18
description: "This is a quick and easy thumnail maker for all those legally attained videos you have in your library!"
image: "cover.png"
categories:
- Scripts
- Media
keywords:
- kodi
- jellyfin
- thumbnails
- archiving dvds
- bash
---
When ripping some old DVDs with classic TV episodes for me and my family to enjoy, I always include a .nfo file and .jpg thumbnail file for Kodi and Jellyfin to use. I use MediaElch to scrape websites like TheTVdb.com for show information, DVD covers, fanart, and show thumbnails. However, theTVdb doesn't always provide individual episode thumbnails. MediaElch provides a thumbnail solution, but it only works for one episode at a time. And when there's 300 episodes, this solution can take quite a while.

Another solution is to use ffmpeg to create a thumbnail. Built into ffmpeg is the ability to create a, in the words of ffmpeg, "Meaningful thumbnail." This is the command to produce a meaningful thumbnail using ffmpeg.
```
ffmpeg -i input.mp4 -vf "thumbnail:scale=640:-2" -frames:v 1 output-thumb.jpg
```

This works great, but again when there's 300 episode, this solution can take quite a while. Let's automate!

With Bash, we can create a for loop to go through every file in the directory.

```
for file in *.mp4; do
   ffmpeg -i "$file" -vf "thumbnail:scale=640:-2" -frames:v 1 "${file%%.mp4}"-thumb.jpg
done

```
With this loop we're telling the computer for every mp4 it finds in the current directory make that file the content of the variable "file". Then we run ffmpeg with that variable as the input file and create a thumbnail. The name of the thumbnail will be the contents of the "file" variable without the ".mp4" extension and adding "-thumb.jpg."

When we run this through our directory of 300 episodes, it works as expected making a thumbnail for every mp4 in the directory.{{< image_right img="S01E01-When-Pants-Attack-thumb.jpg" >}}

Sometimes, however, I want to choose a specific time in the video to create the thumbnail from. For example, some cartoons (for my kids... *cough*) have a title screen at the beginning. This way when my kids (*cough*) are looking through episodes of Jimmy Neutron, they can quickly see which episode "When Pants Attack" is!

Ffmpeg allows for this function too. By simply using the seek function "-ss" with the timestamp we can create a thumbnail at the timestamp pos

```
for file in *.mp4; do
   ffmpeg -ss 00:00:05 -i "$file" -vf "thumbnail:scale=640:-2" -frames:v 1 "${file%%.mp4}"-thumb.jpg
done
```
This works as expected!

I decided to put these two options into a bash script that I could use to quickly make thumbnails for my videos.

```
#!/bin/bash

FORMATS=('*.mp4' '*.mkv' '*.avi') # Let's figure out what video files are in this directory
for ext in ${FORMATS[@]}; do
    test=$(find . -maxdepth 1 -iname "$ext")
    if [[ "$test" ]]; then
        EXT+=("${ext}")
    fi
done

SCALE="scale=640:-2"

Help() {
    echo
    echo "Create thumbnails for every video in afolder"
    echo
    echo "thumbnail [-h|t]"
    echo "options:"
    echo "h     Show this help."
    echo "t     Create thumbnail at a specific Timestamp. (ex. 00:00:05)"
    echo
}

SetTimestamp() {
    echo -n "Make thumbnail at what timestamp? (ex. 00:00:05) "
    read TIMESTAMP
    MakeThumbnail
}

MakeThumbnail() {
    for file in "$PWD"/"${EXT[@]}"; do
        if [[ "$TIMESTAMP" ]]; then
            TIME="-ss $TIMESTAMP"
            VF="-vf $SCALE"
        else
            TIME=""
            VF="-vf thumbnail,$SCALE"
        fi
        echo "Creating thumbnail for ${file##*/}"
        ffmpeg -hide_banner -loglevel error -i "$file" $TIME $VF -frames:v 1 "${file%%.mp4}"-thumb.jpg
    done
}

while getopts ":h:t" option; do
    case $option in
        h)  Help
            exit;;
        t)  SetTimestamp
            exit;;
        \?) echo "Not an Option"
            exit;;
    esac
done

MakeThumbnail
```
This is the first iteration of this little helper script. And it works great for what I need. You can find it at my github page.
