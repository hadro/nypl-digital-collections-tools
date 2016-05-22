#use GNU Parallels to distribute Tesseract jobs across a cluster

if [ -z "$1" ]; then
	echo "please supply a folder for the source files!"
	exit 1
fi


DIRECTORY=$1

DERIV_TYPE_FOR_OCR=bitonal

echo ./files/$DIRECTORY
ls ./files/$DIRECTORY/*$DERIV_TYPE_FOR_OCR.jpg



time ls ./files/$DIRECTORY/*$DERIV_TYPE_FOR_OCR.jpg | parallel --eta --sshloginfile nodeslist \
     --transfer \
     --return {.}.hocr \
     --cleanup \
     "echo {} running on \`hostname\`; /usr/local/bin/tesseract -l eng {} {.} hocr >/dev/null; echo {.}.hocr"


time ls ./files/$DIRECTORY/*$DERIV_TYPE_FOR_OCR.jpg | parallel --eta --sshloginfile nodeslist \
     --transfer \
     --return {.}.txt \
     --cleanup \
     "echo {} running on \`hostname\`; /usr/local/bin/tesseract -l eng {} {.} txt >/dev/null; echo {.}.txt"

