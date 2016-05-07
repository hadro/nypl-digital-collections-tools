# Create a PDF given an item UUID for an item in NYPL's Digital Collections

import requests
import urllib
import os.path
import string
import sys
import subprocess

captures_start = int(raw_input('Enter the first image id of the range here: '))
captures_end = int(raw_input('Enter the last image id of the range here: '))

#Setting the derivative type -- these are the possible deriv type values:
    # b - Center cropped thumbnail .jpeg (100x100 pixels)
    # f - Cropped .jpeg (140 pixels tall with variable width)
    # t - Cropped .gif (150 pixels on the long side)
    # r - Cropped .jpeg (300 pixels on the long side)
    # w - Cropped .jpeg (760 pixels on the long side)
    # q - Cropped .jpeg (1600 pixels on the long side) N.B. Exists only for public domain assets
    # v - Cropped .jpeg (2560 pixels on the long side) N.B. Exists only for public domain assets
    # g - a "full-size" .jpeg derivative N.B. Exists only for public domain assets
print 'For basic PDFs, best choice of derivative is going to be Q'
PDF_deriv_type = raw_input('Enter a derivative type: ')


#Make the item title, and do some cleanup to make it usable as a folder name

title = raw_input('Enter the title you want to use for the folder and for the PDF file: ')

table = string.maketrans("","")
title = str(title).translate(table, string.punctuation).replace("  "," ").replace(" ","_")
#title = title[:65].rpartition('_')[0]
print "folder title will be '"+title+"'"


#Create folder based on the item title
if not os.path.exists('files/'+title):
    os.makedirs('files/'+title)

# #Create the derivs in the item-title folder
img_url_base = "http://images.nypl.org/index.php?id="
derivs = [PDF_deriv_type]

print "Downloading..."

for j in derivs:
	for i in range(int(captures_start),int(captures_end)+1):
		if not os.path.isfile('files/'+title+'/'+str(i)+str(j)+'.jpg'):
			urllib.urlretrieve(img_url_base+str(i)+'&t='+str(j),'files/'+title+'/'+str(i)+str(j)+'.jpg')
			print i, j, "of", ((captures_end+1) - (captures_start))
			i+=1
		else:
			print "file %s as %s deriv type already exists" % (i, j)
			i+=1

#Make PDF using Imagemagick Convert. N.B. This can get messed up if capture names are not always in sequential order; something to fix down the road.
os.system("convert -verbose -density 72x72 -quality 90 -resize 50% ./files/"+title+"/*"+PDF_deriv_type+".jpg ./files/"+title+"/"+title+".pdf")
print "PDF created from %s deriv jpg output" % (PDF_deriv_type)