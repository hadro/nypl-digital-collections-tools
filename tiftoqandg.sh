#convert TIF into G and Q derivatives

if [ -z "$1" ]; then
	echo "please supply a folder for the source files!"
	exit 1
fi

DIRECTORY=$1

DERIV_TYPE_FOR_TIF=u

echo ./files/$DIRECTORY
ls ./files/$DIRECTORY/*$DERIV_TYPE_FOR_TIF.tif

ls ./files/$DIRECTORY/*$DERIV_TYPE_FOR_TIF.tif | time parallel -j+0 --eta 'convert -verbose {} -resize "1600x1600>" {.}q.jpg'

ls ./files/$DIRECTORY/*$DERIV_TYPE_FOR_TIF.tif | time parallel -j+0 --eta 'convert -verbose {} {.}g.jpg'