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

# Check we have mpg123 installed and available for use.
if ! [ -x "$(command -v mpg123)" ]
then
    printf "\n%b=== CRITICAL ===%b\n" "${red_text}" "${end_colour_text}"
    printf "\n'mpg123' could not be found.\n"
    printf "\nPlease check you have 'mpg123' installed on your system.\n"
    printf "\nUnable to continue, exiting program.\n\n"
    exit
fi

# Check we have oggenc installed and available for use.
if ! [ -x "$(command -v oggenc)" ]
then
    printf "\n%b=== CRITICAL ===%b\n" "${red_text}" "${end_colour_text}"
    printf "\n'oggenc' could not be found.\n"
    printf "\nPlease check you have 'vorbis-tools' installed on your system.\n"
    printf "\nUnable to continue, exiting program.\n\n"
    exit
fi

# Show conversion task is running.
printf "\n%b>>> Conversion task is running. <<<%b\n\n" "${yellow_text}" \
"${end_colour_text}"

# Convert audio file (mp3) to wave (wav). 
for in_filename in *.[mM][pP][3]
do
    # Yes, mpg123 has some messed up logic. Output file first and input file 
    # last in the command.
    mpg123 -w "${in_filename%.*}.wav" "$in_filename"
done

# Settings for the conversion. Edit as required.
set_bitrate=160
set_sample_rate=44100

# Convert audio file (wav) to ogg vorbis (ogg). 
for in_filename in *.[wW][aA][vV]
do
    # Set Variable Bit Rate (VBR) to 'set_bitrate' kbps target bitrate.
    oggenc "$in_filename" --resample "$set_sample_rate" -b "$set_bitrate" -o \
    "${in_filename%.*}.ogg"
done

# Create directory 'original_mp3' and then move all (mp3) files into the
# created directory.
mkdir -p original_mp3

for in_filename in *.[mM][pP][3]
do
    mv -f "$in_filename" original_mp3/
done

# Create directory 'intermediate_wav' and then move all (wav) files into the 
# created directory.
mkdir -p intermediate_wav

for in_filename in *.[wW][aA][vV]
do
    mv -f "$in_filename" intermediate_wav/
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
