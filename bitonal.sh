#convert G to bitonal to aid in OCR recognition

if [ -z "$1" ]; then
	echo "please supply a folder for the source files!"
	exit 1
fi

DIRECTORY=$1

DERIV_TYPE_FOR_BITONAL=g

echo ./files/$DIRECTORY
ls ./files/$DIRECTORY/*$DERIV_TYPE_FOR_BITONAL.jpg

time parallel --eta convert -verbose {} -threshold 59% {.}_bitonal.jpg ::: ./files/$DIRECTORY/*$DERIV_TYPE_FOR_BITONAL.jpg