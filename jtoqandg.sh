#convert TIF into G and Q derivatives
PROJECT=quinn
DIRECTORY=quinn
DERIV_TYPE_FOR_OCR=g
DERIV_TYPE_FOR_PDF=q
DERIV_TYPE_FOR_JP2=j

echo $DIRECTORY
ls ./$DIRECTORY/*$DERIV_TYPE_FOR_JP2.jp2

ls $DIRECTORY/000*$DERIV_TYPE_FOR_JP2.jp2 | time parallel -j+0 --eta 'convert -verbose {} -resize "1600x1600>" {.}q.jpg'

ls $DIRECTORY/001*$DERIV_TYPE_FOR_JP2.jp2 | time parallel -j+0 --eta 'convert -verbose {} {.}g.jpg'