#convert TIF into G and Q derivatives
PROJECT=sasbtest2
DIRECTORY=sasbtest2
DERIV_TYPE_FOR_OCR=g
DERIV_TYPE_FOR_PDF=q
DERIV_TYPE_FOR_JP2=j

echo ./files/$DIRECTORY
ls ./files/$DIRECTORY/*$DERIV_TYPE_FOR_JP2.jp2

ls ./files/$DIRECTORY/*$DERIV_TYPE_FOR_JP2.jp2 | time parallel -j+0 --eta 'convert -verbose {} -resize "1600x1600>" {.}q.jpg'

ls ./files/$DIRECTORY/*$DERIV_TYPE_FOR_JP2.jp2 | time parallel -j+0 --eta 'convert -verbose {} {.}g.jpg'