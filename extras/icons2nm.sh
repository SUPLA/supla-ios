#!/bin/bash

process_image() {
  NAME=$1
  SUFFIX=$2
  if [ -e $NAME$SUFFIX ]; then
    [ -e $NAME-nightmode$SUFFIX ] && rm $NAME-nightmode$SUFFIX
    magick $NAME$SUFFIX -channel RGB +level-colors "#b4b7ba", $NAME-nightmode$SUFFIX
  else
    echo $NAME$SUFFIX not found!
  fi
}

while read -r line
do
   process_image $line "@2x.png"
   process_image $line "@3x.png"
done < "list.txt"
