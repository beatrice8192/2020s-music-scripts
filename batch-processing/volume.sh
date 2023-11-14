
list=""
option=$1

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

    ffmpeg -i "$input" -af "volume="$option"dB" "${input%.mp3}"."$option".mp3
done
