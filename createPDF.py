# Create a PDF given an item UUID for an item in NYPL's Digital Collections

import requests
import urllib
import os.path
import string
import sys
import subprocess

#Aside from the modules above, you'll need to get an API key for the NYPL metadata API -- available here: http://api.repo.nypl.org/sign_up

#Paste the token you'll get via email below
token = ''
base = 'http://api.repo.nypl.org/api/v1/'


#Set UUID for the item you want to get the captures of
#UUID = ''
UUID = raw_input("What UUID please?")

#Setting the derivative type -- these are the possible deriv type values:
    # b - Center cropped thumbnail .jpeg (100x100 pixels)
    # f - Cropped .jpeg (140 pixels tall with variable width)
    # t - Cropped .gif (150 pixels on the long side)
    # r - Cropped .jpeg (300 pixels on the long side)
    # w - Cropped .jpeg (760 pixels on the long side)
    # q - Cropped .jpeg (1600 pixels on the long side) N.B. Exists only for public domain assets
    # v - Cropped .jpeg (2560 pixels on the long side) N.B. Exists only for public domain assets
    # g - a "full-size" .jpeg derivative N.B. Exists only for public domain assets
#Solicit the UUID from the users
print 'For basic PDFs, best choice of derivative is going to be Q'
PDF_deriv_type = raw_input('Enter a derivative type: ')

#Make sure it's a valid UUID
if len(UUID) != 36:
	sys.exit("That doesn't look like a UUID -- try again!")
else:
	print "OK, that ID looks correct, looking it up now..."


#function to get captures for a given UUID
def getCaptures(uuid):
    url = base + 'items/' + uuid + '?withTitles=yes&per_page=1000'
    call = requests.get(url, headers={'Authorization ':'Token token=' + token})
    return call.json()

def getItem(uuid):
	url = base + 'items/mods/' + uuid + '?per_page=1000'
	call = requests.get(url, headers={'Authorization':'Token token=' + token}) 
	return call.json()

def getContainer(uuid):
	url = base + '/collections/' + uuid + '?per_page=1000'
	call = requests.get(url, headers={'Authorization':'Token token=' + token}) 
	return call.json()


captureResponse = getCaptures(UUID)
containerResponse = getContainer(UUID)
itemResponse = getCaptures(UUID)

isContainer = int(containerResponse['nyplAPI']['response']['numItems'])
number_of_captures = int(captureResponse['nyplAPI']['response']['numResults'])

#Check to make sure we don't accidentally have a container or a collection UUID here
if isContainer > 0 and number_of_captures > 0:
	sys.exit("This is a container, let's bail.")
#If we're good to go, either get the number of capture IDs, or go to the item UUID and get the # of captures there
else:
	print "OK, this is a usable UUID, let's see what we can do with it..."
	if number_of_captures > 0: 
		print "%s captures total" % (number_of_captures)
		print UUID
	else:
		print "No captures in the API response! Trying to see if this is a capture UUID, not an item UUID..."
		UUID = getItem(UUID)['nyplAPI']['response']['mods']['identifier'][-1]['$']
		itemResponse = getCaptures(UUID)
		number_of_captures = int(itemResponse['nyplAPI']['response']['numResults'])
		print "Correct item UUID is "+UUID
		print "Item UUID has %s captures total" % (number_of_captures)

#OK, enough checking, let's get the actual captures!
captures = []



for i in range(number_of_captures):
	captureID = itemResponse['nyplAPI']['response']['capture'][i]['imageID']
	captures.append(captureID)

#print captures

#Check to see if there are derivs large enough to use to get good OCR results
high_res_captures = itemResponse['nyplAPI']['response']['capture'][0]['imageLinks']['imageLink']

if ("t="+str(PDF_deriv_type)) in str(high_res_captures):
	print "Good news! This item has deriv type you're looking for!"
else:
	sys.exit(":-( the requested derivs for this item are missing, make sure this is a public domain item?")

#Grab the item title, and do some cleanup to make it usable as a folder name
table = string.maketrans("","")
title = str(itemResponse['nyplAPI']['response']['capture'][0]['title']).translate(table, string.punctuation).replace("  "," ").replace(" ","_")
title = title[:65].rpartition('_')[0]
print "folder title will be '"+title+"'"

#Create folder based on the item title
if not os.path.exists(title):
    os.makedirs(title)

open(title+'/'+title+'.txt', 'w')

# write image IDs to a file
for i in range(number_of_captures):
	with open(title+'/'+title+'.txt', 'a') as myfile:
		myfile.write(captures[i]+'\n')
	i+=1
print "text file with image IDs created at "+title+'.txt!'

# #Create the derivs in the item-title folder
img_url_base = "http://images.nypl.org/index.php?id="
derivs = [PDF_deriv_type]

for j in derivs:
	for i in range(number_of_captures):
		if not os.path.isfile(title+'/'+str("%04d" %i)+'_'+str(captures[i])+str(j)+'.jpg'):
			urllib.urlretrieve(img_url_base+str(captures[i])+'&t='+str(j),title+'/'+str("%04d" %i)+'_'+str(captures[i])+str(j)+'.jpg')
			print captures[i], j, i+1, "of", number_of_captures
			i+=1
		else:
			print "file %s as %s deriv type already exists" % (captures[i], j)
			i+=1

#Make PDF using Imagemagick Convert. N.B. This can get messed up if capture names are not always in sequential order; something to fix down the road.
os.system("convert -verbose -density 72x72 -quality 90 -resize 50%\ ls ./"+title+"/*"+PDF_deriv_type+".jpg "+title+"/"+title+".pdf")
print "PDF created from %s deriv jpg output" % (PDF_deriv_type)