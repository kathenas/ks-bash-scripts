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

# If script run with 'sh', inform to execute directly or invoke with 'bash'.
if [ ! "$BASH_VERSION" ] ; then
    printf "\n%b=== WARNING ===%b\n" "${yellow_text}" "${end_colour_text}"
    printf "\nPlease do not use %bsh%b to run this script %b%s%b. Run directly \
e.g. %b./%s%b if the script is set executable or use %bbash %s%b instead \
of %bsh %s%b.\n\n" 1>&2 "${yellow_text}" "${end_colour_text}" "${yellow_text}" \
"$0" "${end_colour_text}" "${green_text}" "$0" "${end_colour_text}" \
"${green_text}" "$0" "${end_colour_text}" "${yellow_text}" "$0" \
"${end_colour_text}"
    exit 1
fi

# Check we have lame installed and available for use.
if ! [ -x "$(command -v lame)" ]
then
    printf "\n%b=== CRITICAL ===%b\n" "${red_text}" "${end_colour_text}"
    printf "\n'lame' could not be found.\n"
    printf "\nPlease check you have 'lame' installed on your system.\n"
    printf "\nUnable to continue, exiting program.\n\n"
    exit
fi

# Show conversion task is running.
printf "\n%b>>> Conversion task is running. <<<%b\n\n" "${yellow_text}" \
"${end_colour_text}"

# Convert audio file (wav) to (mp3). 
for in_filename in *.[wW][aA][vV]
do
    lame "$in_filename" "${in_filename%.*}.mp3"
done

# Create directory 'original_wav' and then move all (wav) files into that
# created directory.
mkdir -p original_wav

for in_filename in *.[wW][aA][vV]
do
    mv -f "$in_filename" original_wav/
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
