
list=$1

function file_norm
{
    file=$1
    newfile=$(echo $file | sed "s| |_|g" | tr -d '(){},?!:;"' | tr -d "'")
    mv "$file" "$newfile"
    echo "$newfile"
}
function calculate_amplify
{
    mean_volume=$(echo $1 | cut -d '.' -f 1)
    amplify=0
    if [ $mean_volume -gt -15 ]; then
        amplify=$(( (-15) - $mean_volume ))
    fi
    echo $amplify
}
# for file in *; do
#    file_norm $file
# done

if [[ "$list" == "" ]]; then
    list=$(ls *.mp3)
fi
for file in $list; do
    if [[ $file =~ split.sh ]]; then
        continue
    fi
    input=$file

    ffmpeg -i "$input" -af silencedetect=noise=-30dB:d=0.5 -f null - 2>&1 | grep "silence_end" > "$input".vol.txt
    start=0
    i=1
    while IFS= read -r line; do
        end=$(echo $line | sed "s/.*silence_end//g" | awk '{print $2}')
        duration=$(echo $line | sed "s/.*silence_duration//g" | awk '{print $2}' | cut -d '.' -f 1)
        echo end $end
        echo duration $duration
        if [ $duration -ge 1 ]; then
            index=$(echo $(( $i + 1000 )) | cut -c 2-)
            end=$(echo "$end - 1" | bc)
            ffmpeg -y -ss $start -t $(echo "$end - $start" | bc) -i "$input" "${input%.mp3}"."$index".mp3
            start=$end
            i=$(( $i + 1 ))
        fi
    done < "$input".vol.txt

    index=$(echo $(( $i + 1000 )) | cut -c 2-)
    length=$(ffprobe -i $input -show_entries format=duration -v quiet -of csv="p=0")
    ffmpeg -y -ss $start -t $(echo "$length - $start" | bc) -i "$input" "${input%.mp3}"."$index".mp3
done
