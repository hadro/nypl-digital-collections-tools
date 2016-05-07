#convert TIF into G and Q derivatives
PROJECT=sasbtest2
DIRECTORY=sasbtest2
DERIV_TYPE_FOR_OCR=g
DERIV_TYPE_FOR_PDF=q
DERIV_TYPE_FOR_TIF=u

echo ./files/$DIRECTORY
ls ./files/$DIRECTORY/*$DERIV_TYPE_FOR_TIF.tif

ls ./files/$DIRECTORY/*$DERIV_TYPE_FOR_TIF.tif | time parallel -j+0 --eta 'convert -verbose {} -resize "1600x1600>" {.}q.jpg'

ls ./files/$DIRECTORY/*$DERIV_TYPE_FOR_TIF.tif | time parallel -j+0 --eta 'convert -verbose {} {.}g.jpg'

# ls $DIRECTORY/*$DERIV_TYPE_FOR_OCR.jpg | parallel -j+0 --eta 'tesseract -l eng {} {.} hocr >/dev/null'

# for page in `ls ./$DIRECTORY/000*$DERIV_TYPE_FOR_JP2.jp2`
# 	do
# 	    file_name=$(basename $page)
# 	    file_name_without_ext=${file_name%$DERIV_TYPE_FOR_JP2.*}
# 	    convert -verbose ./$DIRECTORY/$file_name -resize "1600x1600>" ./$DIRECTORY/$file_name_without_ext\q.jpg
# 	    convert -verbose ./$DIRECTORY/$file_name ./$DIRECTORY/$file_name_without_ext\g.jpg 
# 	done
