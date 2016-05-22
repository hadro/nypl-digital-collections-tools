#!/bin/bash

#adapted, and abused, from original script pasted here: https://github.com/jbarlow83/OCRmyPDF/issues/8


# #Things to add:
# - solicit variables directly from users, so they can supply e.g. item UUID DONE
# - Translation from capture UUID to parent item UUID DONE
# - Check to see if derivatives are already created, and if so, don't download them DONE
# - Create directory based on item title, or some other element of the item metadata? DONE
# - Check first to see if high-res assets exist before trying to proceed with the scrape part of the script DONE
# - fix sort for the cases where item captures aren't in chronological order DONE
# - figure out paging in order to deal with those cases where items will have more than 500 captures (do we want to deal with these cases?)

#set some variables for the rest of the script
PROJECT=$1
DIRECTORY=./files/$1
DERIV_TYPE_FOR_OCR=bitonal
DERIV_TYPE_FOR_PDF=q


# #run the scrape script to gather the derivatives that feed the PDF and OCR processes
#python scrape.py $PROJECT

#Make bitonal files!
sh bitonal.sh $PROJECT

#Make PDF using Imagemagick Convert, using created date sort not alpha sort since capture names might not always be in sequential order:

if [ -f "$DIRECTORY/$PROJECT.pdf" ]
then
	echo "$PROJECT.pdf found."
else
	time convert -verbose -density 72x72 -quality 90 -resize 50% `ls ./$DIRECTORY/*\$DERIV_TYPE_FOR_PDF.jpg` $DIRECTORY/$PROJECT.pdf
	# Use the below line if the above is too low-res
	# time convert -verbose -density 72x72 `ls ./$DIRECTORY/*\$DERIV_TYPE_FOR_PDF.jpg` $DIRECTORY/$PROJECT.pdf
	echo "PDF created from $DERIV_TYPE_FOR_PDF deriv jpg output"
fi


# OCR

# OCR each page, and produce PDF file(s) containing the background (=text) layer

# CAPTURE=1

# for page in `ls -t ./$DIRECTORY/*\$DERIV_TYPE_FOR_OCR.jpg`	
# 	do
# 	    file_name=$CAPTURE\_$(basename $page)
# 	    file_name_without_ext=${file_name%.*}

# 	    echo "Character recognition $page"
# 	    tesseract -l eng $page ./$DIRECTORY/$file_name_without_ext hocr >/dev/null
# 	    python3 /usr/local/lib/python3.5/site-packages/ocrmypdf/hocrTransform.py -r 600 ./$DIRECTORY/$file_name_without_ext.hocr ./$DIRECTORY/$file_name_without_ext.pdf
# 	    # Delete temporary hocr file
# 	    rm ./$DIRECTORY/*$DERIV_TYPE_FOR_OCR.hocr
# 	    rm ./$DIRECTORY/*$DERIV_TYPE_FOR_OCR.txt
# 	    echo "done with page " $CAPTURE
# 	    ((CAPTURE++))
# 	done

# #Let's try this with parallels instead...
# time parallel -j+0 --eta 'tesseract -l eng {} {.} hocr > dev/null' ::: $DIRECTORY/*$DERIV_TYPE_FOR_OCR.jpg

# time parallel -j+0 --eta 'python3 /usr/local/lib/python3.5/site-packages/ocrmypdf/hocrTransform.py -r 600 {} {.}.pdf' ::: $DIRECTORY/*$DERIV_TYPE_FOR_OCR.hocr 

#time ls $DIRECTORY/*$DERIV_TYPE_FOR_OCR.jpg | parallel -j+0 --eta 'tesseract -l eng {} {.} hocr >/dev/null'
#time ls $DIRECTORY/*$DERIV_TYPE_FOR_OCR.jpg | parallel -j+0 --eta 'tesseract -l eng {} {.} txt >/dev/null'


#USE DISTRIBUTED COMPUTING POWERS!
sh distributed.sh $PROJECT




time ls $DIRECTORY/*$DERIV_TYPE_FOR_OCR.hocr | parallel -j+0 --eta 'python3 /usr/local/lib/python3.5/site-packages/ocrmypdf/hocrTransform.py -r 600 {} {.}.pdf' 
# #rm $DIRECTORY/*$DERIV_TYPE_FOR_OCR.hocr
# #rm $DIRECTORY/*$DERIV_TYPE_FOR_OCR.txt
echo "done with hocr files for $DIRECTORY"

# # Join PDF files into one file that contains all OCR backgrounds
time pdftk `ls ./$DIRECTORY/*\$DERIV_TYPE_FOR_OCR.pdf` output $DIRECTORY/$PROJECT\_ocr.pdf
echo "done with pdftk part 1"
# Delete temporary scan*.pdf files
#rm ./$DIRECTORY/*$DERIV_TYPE_FOR_OCR.pdf

# Merge OCR background PDF into the main PDF document
time pdftk $DIRECTORY/$PROJECT.pdf multibackground $DIRECTORY/$PROJECT\_ocr.pdf output $DIRECTORY/$PROJECT\_final.pdf
#rm $DIRECTORY/$PROJECT\_ocr.pdf
#mv $DIRECTORY/$PROJECT\_final.pdf $DIRECTORY/$PROJECT.pdf

echo "done with pdftk part 2";

echo "You have now created and OCRed a PDF of $PROJECT. Good work!";

#From Ryan Baumann: 
#https://ryanfb.github.io/etc/2014/11/13/command_line_ocr_on_mac_os_x.html
#parallel --bar "tesseract {} {.} pdf 2>/dev/null" ::: page_*.tif
#ls -t ./$DIRECTORY/*\$DERIV_TYPE_FOR_OCR.jpg | parallel -j+0 --eta 'tesseract -l eng {} {.} hocr >/dev/null' 