# Create a PDF given an item UUID for an item in NYPL's Digital Collections

import requests
import urllib
import os.path
import string
import sys
import subprocess

captures_start = int(raw_input('Enter the first image id of the range here: '))
captures_end = int(raw_input('Enter the last image id of the range here: '))

tif_deriv_type = 'u'


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
# #Create the two kinds of derivs in the item-title folder
img_url_base = "http://images.nypl.org/index.josh.php?id="
derivs = [tif_deriv_type]#[OCR_deriv_type,PDF_deriv_type]

print "Downloading..."

for j in derivs:
	for i in range(int(captures_start),int(captures_end)+1):
		if not os.path.isfile('files/'+title+'/'+str("%04d" %i)+'_'+str(j)+'.tif'):
			urllib.urlretrieve(img_url_base+str(i)+'&t='+str(j)+'&download=1', 'files/'+title+'/'+str(i)+str(j)+'.tif')
			print j, i
			i+=1
		else:
			print "file %s as %s deriv type already exists" % (i, j)
			i+=1