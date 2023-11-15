#!/bin/bash

# Author: Phil Wyett - philip.wyett@kathenas.org
#
# Website: https://kathenas.org
#
# Buy me a coffee: https://www.buymeacoffee.com/kathenasorg
#
# License: GPL3+ - See 'license.txt' in root directory of repository.

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

printf "%s %s \n${red_text}DEVELOPER NOTE:${end_colour_text} This script is \
not finished and should be regarded a Work In Progress (WIP).\n"

# Check we have ffmpeg installed and available for use.
if ! [ -x "$(command -v ffmpeg)" ]
then
    printf "\n%b=== CRITICAL ===%b\n" "${red_text}" "${end_colour_text}"
    printf "\n'ffmpeg' could not be found.\n"
    printf "\nPlease check you have 'ffmpeg' installed on your system.\n"
    printf "\nUnable to continue, exiting program.\n\n"
    exit
fi

# Check we have 'nproc' installed and available for use.
if ! [ -x "$(command -v nproc)" ]
then
    printf "\n%b=== CRITICAL ===%b\n" "${red_text}" "${end_colour_text}"
    printf "\n'nproc' could not be found.\n"
    printf "\nPlease check you have 'coreutils' installed on your system.\n"
    printf "\nUnable to continue, exiting program.\n\n"
    exit
fi

# Check we have 'ssmtp' installed and available for use.
if ! [ -x "$(command -v ssmtp)" ]
then
    printf "\n%b=== CRITICAL ===%b\n" "${red_text}" "${end_colour_text}"
    printf "\n'ssmtp' could not be found.\n"
    printf "\nPlease check you have 'ssmtp' installed on your system.\n"
    printf "\nUnable to continue, exiting.\n\n"
    exit
fi

# Get host CPU thread count.
host_cpu_thread_count=$(nproc --all)

printf "\n%bINFO:%b CPU thread count for this system is: %d\n" \
"${yellow_text}" "${end_colour_text}" "${host_cpu_thread_count}"

printf "\n%bINFO:%b Choose number of threads to use between 0 and \
$((host_cpu_thread_count)). Selecting '0' is auto - maximum \
multi-threading.\n\n" "${yellow_text}" "${end_colour_text}"

# Get users desired amount of threads to use from host system.
read -rp "Choose number of threads to use (max: $((host_cpu_thread_count))): " \
host_cpu_threads_to_use

printf "\n%bINFO:%b Using $((host_cpu_threads_to_use)) thread(s) for this \
job.\n" "${yellow_text}" "${end_colour_text}"

# Get video files resolution.
for in_filename in *.[mM][pPkK][4vV]
do
    if [ -e "$in_filename" ]
    then
        input_video_resolution=$(ffprobe -v error -select_streams v:0 \
            -show_entries stream=width,height -of csv=s=x:p=0 "$in_filename")
        printf "\n%bINFO:%b Input video resolution is: \
        $input_video_resolution\n\n" "${yellow_text}" "${end_colour_text}"
    else
        printf "\n%bINFO:%b No valid files to process. Exiting...\n" \
        "${yellow_text}" "${end_colour_text}"
        printf "\nIf you find this script valuable. Please donate if \
        possible.\n"
        printf "\nDonate at https://www.buymeacoffee.com/kathenasorg\n"
        sleep 4
        exit
    fi
done

#
read -rp "Do you wish to rescale the video (current: $input_video_resolution) \
(y/n): " user_rescale_video
if [ "$user_rescale_video" = "y" ] || [ "$user_rescale_video" = "Y" ] ; then

    printf "\n%bINFO:%b For common display resolution information \
    see: https://en.wikipedia.org/wiki/List_of_common_resolutions\n\n" \
    "${yellow_text}" "${end_colour_text}"

    # Get user desired video scaling.
    read -rp "Choose video scale - (current: $input_video_resolution): " \
    output_video_resolution
else
    printf "\n%bINFO:%b Current video resolution of '%s' will be used.\n" \
    "${yellow_text}" "${end_colour_text}" "{$input_video_resolution}"
    output_video_resolution=$input_video_resolution
fi

# Get video display aspect ratio (DAR).
for in_filename in *.[mM][pPkK][4vV]
do
    if [ -e "$in_filename" ]
    then
        input_video_dar=$(ffprobe -v error -select_streams v:0 \
            -show_entries stream=display_aspect_ratio -of csv=s=x:p=0 \
            "$in_filename")
        printf "\n%bINFO:%b Display Aspect Ratio (DAR) is: \
        $input_video_dar\n\n" "${yellow_text}" "${end_colour_text}"
    else
        printf "\n%bINFO:%b No valid files to process, exiting program.\n" \
        "${yellow_text}" "${end_colour_text}"
        printf "\nIf you find this script valuable. Please donate if \
        possible.\n"
        printf "\nDonate at https://www.buymeacoffee.com/kathenasorg\nn"
        sleep 4
        exit
    fi
done

# Constant Rate Factor (CRF) setting.
#
# For x264 values are '0' (best quality) to '51' (lowest quality).
#
# This is the Kathenas default value, ffmpeg default is 23.
ks_default_output_crf=25

read -rp "Do you wish to change the Constant Rate Factor (CRF) (current: \
$ks_default_output_crf) (y/n): " user_change_dar
if [ "$user_change_dar" = "y" ] || [ "$user_change_dar" = "Y" ] ; then

    printf "\n%bINFO:%b For Constant Rate Factor (CRF) information \
    see: https://trac.ffmpeg.org/wiki/Encode/H.264\n\n" "${yellow_text}" \
    "${end_colour_text}"

    # Get user desired CRF.
    read -rp "Choose Constant Rate Factor (CRF) - (current: \
    $ks_default_output_crf): " output_crf
else
    output_crf=$ks_default_output_crf
fi

printf "\n%bINFO:%b Constant Rate Factor (CRF) set to %d for this job.\n" \
"${yellow_text}" "${end_colour_text}" "${output_crf}"

# Show conversion task is running.
printf "\n%b>>> Conversion task is running. <<<%b\n" "${yellow_text}" \
"${end_colour_text}"

for input_filename in *.[mM][pPkK][4vV]
do
    # Convert our video.
    ffmpeg -v warning \
        -ss 00:00:05 -to 00:00:20 \
        -threads $((host_cpu_threads_to_use)) \
        -i "$input_filename" \
        -threads $((host_cpu_threads_to_use)) \
        -vf "scale=$output_video_resolution:flags=lanczos,setsar=1:1, \
            setdar=16/9" \
        -c:v libx264 \
        -crf $((output_crf)) \
        -profile:v main \
        -pix_fmt yuv420p \
        -c:a aac -ac 2 \
        "WIP_${input_filename%.*}.mp4"

    # Rename converted file to original filename.
    mv -f "WIP_${input_filename%.*}.mp4" "${input_filename%.*}_TEST.mp4"
done

# Show conversion task has ended.
printf "\n%b>>> Conversion task is complete. <<<%b\n" "${green_text}" \
"${end_colour_text}"

# Send email to specified recipient informing them that the task is complete.
sender="bash.scripts.runner@kathenas.org"
recipient="philip.wyett@kathenas.org"
subject="FFMPEG: Task status - complete."
body="FFMPEG processing task on host machine '${HOSTNAME}' is complete."

# Construct and send out our email.
printf "Subject: %s\n\n%s" "${subject}" "${body}" | ssmtp -f "${sender}" \
"${recipient}"

# Shameless plug to support poor Free/Open Source developers like myself who
# make content available to people for free with no strings attached.
printf "\nPlease consider supporting Free/Open Source developers like myself \
who provide content for free. Voluntary donations can be made at \
%bhttps://www.buymeacoffee.com/kathenasorg%b\n\n" "${green_text}" \
"${end_colour_text}"
