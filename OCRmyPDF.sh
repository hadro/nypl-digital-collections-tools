#!/bin/bash

#adapted, and abused, from original script pasted here: https://github.com/jbarlow83/OCRmyPDF/issues/8
#Also significantly inspired by Ryan Baumann's post here: #https://ryanfb.github.io/etc/2014/11/13/command_line_ocr_on_mac_os_x.html
#Particularly the bit in footnote 3, which turned me onto GNU Parallel!

## SETUP

#set some variables for the rest of the script
PROJECT=$1
DIRECTORY=./files/$1
DERIV_TYPE_FOR_OCR=bitonal
DERIV_TYPE_FOR_PDF=q

## DOWNLOAD IMAGES

# #run the scrape script to gather the derivatives that feed the PDF and OCR processes
python scrape.py $PROJECT

## IMAGE PROCESSING

#Make bitonal files!
#Takes the largest derivative type and uses a threshold to make smaller, bitonal files that are better and faster for Tesseract processing
sh bitonal.sh $PROJECT

## For really nasty files, particularly unevenly lit images (microfilm, I'm looking at you...), you'll need something more powerful than basic Imagemagick convert. Uncomment the line below. Basically, instead of applying basic threshold, uses Imagemagick localthresh process: http://www.fmwconcepts.com/imagemagick/localthresh/index.php Much more processor intensive, but uses a radius approach to threshold that works a ton better for uneven imaging, particularly microfilm
#sh localthreshold.sh $PROJECT

#Make PDF using Imagemagick
if [ -f "$DIRECTORY/$PROJECT.pdf" ]
then
	echo "$PROJECT.pdf found."
else
	time convert -verbose -density 72x72 -quality 90 -resize 50% `ls ./$DIRECTORY/*\$DERIV_TYPE_FOR_PDF.jpg` $DIRECTORY/$PROJECT.pdf
	# Use the below line if the above is too low-res
	# time convert -verbose -density 72x72 `ls ./$DIRECTORY/*\$DERIV_TYPE_FOR_PDF.jpg` $DIRECTORY/$PROJECT.pdf
	echo "PDF created from $DERIV_TYPE_FOR_PDF deriv jpg output"
fi

## OCR

#USE DISTRIBUTED COMPUTING POWERS!
#E.g., use GNU Parallel to distribute Tesseract OCR process across a cluster of IP addresses
sh distributed.sh $PROJECT

## MERGING INTO PDF

# Produce PDF file from each hocr file that will be the background (=text) layer for the final PDF page

time ls $DIRECTORY/*$DERIV_TYPE_FOR_OCR.hocr | parallel -j+0 --eta 'python3 /usr/local/lib/python3.5/site-packages/ocrmypdf/hocrTransform.py -r 600 {} {.}.pdf' 
#Uncomment these if you want script to clean up after itself...
# #rm $DIRECTORY/*$DERIV_TYPE_FOR_OCR.hocr
# #rm $DIRECTORY/*$DERIV_TYPE_FOR_OCR.txt
echo "done with hocr files for $DIRECTORY"

# # Join PDF files into one file that contains all OCR background files
time pdftk `ls ./$DIRECTORY/*\$DERIV_TYPE_FOR_OCR.pdf` output $DIRECTORY/$PROJECT\_ocr.pdf
echo "done with pdftk part 1"
# Uncomment to delete temporary pdf files
#rm ./$DIRECTORY/*$DERIV_TYPE_FOR_OCR.pdf

# Merge full-color page images with the hocr background file containing the embedded text
time pdftk $DIRECTORY/$PROJECT.pdf multibackground $DIRECTORY/$PROJECT\_ocr.pdf output $DIRECTORY/$PROJECT\_final.pdf
# Uncomment to cleanup temporary pdfs
#rm $DIRECTORY/$PROJECT\_ocr.pdf
#mv $DIRECTORY/$PROJECT\_final.pdf $DIRECTORY/$PROJECT.pdf

echo "done with pdftk part 2";

echo "You have now created and OCRed a PDF of $PROJECT. Good work!";