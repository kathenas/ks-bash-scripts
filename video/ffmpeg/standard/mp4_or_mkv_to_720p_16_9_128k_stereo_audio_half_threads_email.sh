#!/bin/bash

#
# Author: Phil Wyett - philip.wyett@kathenas.org
#
# Website: https://kathenas.org
#
# Buy me a coffee: https://www.buymeacoffee.com/kathenasorg
#
# License: GPL3+ - See 'license.txt' in root directory of repository.
#

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

printf "\n%bINFO:%b Half the total thread count will be used i.e. %d\n" \
"${yellow_text}" "${end_colour_text}" $((host_cpu_thread_count / 2))

printf "\n%bINFO:%b For this script with selectable thread count, see: \
%bhttps://github.com/kathenas/ks-bash-scripts%b\n" "${yellow_text}" \
"${end_colour_text}" "${green_text}" "${end_colour_text}"

# Show conversion task is running.
printf "\n%b>>> Conversion task is running. <<<%b\n" "${yellow_text}" \
"${end_colour_text}"

for in_filename in *.[mM][pPkK][4vV]
do
    # Convert our video.
    ffmpeg -v warning \
        -threads $((host_cpu_thread_count / 2)) \
        -i "$in_filename" \
        -threads $((host_cpu_thread_count / 2)) \
        -vf "scale=1280x720:flags=lanczos,setsar=1:1,setdar=16/9" \
        -c:v libx264 \
        -crf 25 \
        -profile:v main \
        -pix_fmt yuv420p \
        -c:a aac -ac 2 \
        "WIP_${in_filename%.*}.mp4"

    # Remove original file.
    rm -f "$in_filename"

    # Rename converted file to original filename.
    mv -f "WIP_${in_filename%.*}.mp4" "${in_filename%.*}.mp4"
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

# Show conversion task has ended.
printf "\n%b>>> Conversion task is complete. <<<%b\n" "${green_text}" \
"${end_colour_text}"

# Shameless plug to support poor Free/Open Source developers like myself who
# make content available to people for free with no strings attached.
printf "\nPlease consider supporting Free/Open Source developers like myself \
who provide content for free. Voluntary donations can be made at \
%bhttps://www.buymeacoffee.com/kathenasorg%b\n\n" "${green_text}" \
"${end_colour_text}"
