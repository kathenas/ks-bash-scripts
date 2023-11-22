#!/bin/bash

# Author: Phil Wyett - philip.wyett@kathenas.org
#
# Website: https://kathenas.org
#
# Buy me a coffee: https://www.buymeacoffee.com/kathenasorg
#
# License: GPL3+ - See 'license.txt' in root directory of repository

# Define some colours for output text.
red_text='\033[0;31m'
yellow_text='\033[0;33m'
green_text='\033[32m'
end_colour_text='\033[0m'

# Check we have ffmpeg installed and available for use.
if ! [ -x "$(command -v ffmpeg)" ]
then
    printf "\n%b=== CRITICAL ===%b\n" "${red_text}" "${end_colour_text}"
    printf "\n'ffmpeg' could not be found.\n"
    printf "\nPlease check you have 'ffmpeg' installed on your system.\n"
    printf "\nUnable to continue, exiting program.\n\n"
    exit
fi

# Information.
#
# The gnome screencast recorder often produces video with poor colouring. The settings below can
# be manipulated to produce a better final production mp4 file for future use, be that on your
# website or social media etc.

# Show conversion task is running.
printf "\n%b>>> Conversion task is running. <<<%b\n\n" "${yellow_text}" \
"${end_colour_text}"

# Settings for the conversion. Edit as required.
set_gamma=1.00
set_contrast=1.00
set_brightness=0.00
set_saturation=1.20

#
# Convert gnome internal screencast encoder vp9 webm file to mp4.
#
for in_filename in *.[wW][eE][bB][mM]
do
    ffmpeg -i "$in_filename" \
        -vf eq=gamma="$set_gamma":contrast="$set_contrast":brightness="$set_brightness":saturation="$set_saturation" \
        -crf 10 \
        -codec:v libx264 \
        "${in_filename%.*}.mp4"
done

# Show conversion task has ended.
printf "\n%b>>> Conversion task is complete. <<<%b\n" "${green_text}" \
"${end_colour_text}"

# Shameless plug to support poor Free/Open Source developers like myself who
# make content available to people for free with no strings attached.
printf "\nPlease consider supporting Free/Open Source developers like myself \
who provide content for free. Voluntary donations can be made at \
%bhttps://www.buymeacoffee.com/kathenasorg%b\n\n" "${green_text}" \
"${end_colour_text}"
