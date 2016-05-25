#!/usr/bin/python

#Get just the images IDs, in order, for items that are not PD


import requests
import urllib
import os.path
import string
import sys
import re
import config as cfg

# A basic script to help get just the relevant imageIDs, in order, for a Digital Collections item
# Just plug in the UUID for the item that you find on the Digital Collections item page

#Aside from the modules above, you'll need to get an API key for the NYPL metadata API
#API key available here: http://api.repo.nypl.org/sign_up

#Paste the API token you got via email
token = cfg.api_token

#Set UUID for the item you want to get the captures of
#uuid = 'e3e5b110-87d8-0133-ea09-00505686d14e'
uuid = raw_input("What UUID please?")

api_base = 'http://api.repo.nypl.org/api/v1/'
img_url_base = "http://images.nypl.org/index.php?id="
captures = []

#functions to get captures for a given UUID depending on whether it's a capture, item, or a container/collection
def getCaptures(uuid):
    url = api_base + 'items/' + uuid + '?withTitles=yes&per_page=2000'
    call = requests.get(url, headers={'Authorization ':'Token token=' + token})
    return call.json()

def getItem(uuid):
	url = api_base + 'items/mods/' + uuid + '?per_page=2000'
	call = requests.get(url, headers={'Authorization':'Token token=' + token}) 
	return call.json()

def getContainer(uuid):
	url = api_base + '/collections/' + uuid + '?per_page=2000'
	call = requests.get(url, headers={'Authorization':'Token token=' + token}) 
	return call.json()

capture_response = getCaptures(uuid)
item_response = getItem(uuid)
container_response = getContainer(uuid)

is_container = int(container_response['nyplAPI']['response']['numItems'])
number_of_captures = int(capture_response['nyplAPI']['response']['numResults'])

#######

#Let's get started!

#Make sure it's a valid UUID
if re.search(r'([^a-f0-9-])', uuid) or len(uuid) != 36:
	sys.exit("That doesn't look like a correct UUID -- try again!")
else:
	print "OK, that ID is well formed, looking it up now..."

#Check to make sure we don't accidentally have a container or a collection UUID here
# if is_container > 0 and number_of_captures > 0:
# 	sys.exit("This is a container, this script is meant to pull images from single items only.")
#If we're good to go, either get the number of capture IDs, or go to the item UUID and get the # of captures there
#else:
print "Yep, this is a usable UUID, let's see what we can do with it..."
if number_of_captures > 0: 
	print "%s captures total" % (number_of_captures)
	print uuid
else:
	print "No captures in the API response! Trying to see if this is a capture UUID instead of an item UUID..."
	uuid = getItem(uuid)['nyplAPI']['response']['mods']['identifier'][-1]['$']
	item_response = getCaptures(uuid)
	capture_response = getCaptures(uuid)
	number_of_captures = int(item_response['nyplAPI']['response']['numResults'])
	print "Ah yes -- correct item UUID is " + uuid
	print "Item UUID has %s capture(s) total" % (number_of_captures)

#OK, enough checking, let's get the actual captures!
for i in range(number_of_captures):
	capture_id = capture_response['nyplAPI']['response']['capture'][i]['imageID']
	captures.append(capture_id)

#Grab the item title, and do some cleanup to make it usable as a folder name
table = string.maketrans("","")
title = str(capture_response['nyplAPI']['response']['capture'][0]['title']).translate(table, string.punctuation).replace("  "," ").replace(" ","_")
title = title[:100]+'_'+uuid
print "folder title will be '"+title+"'"

#Create folder based on the item title
if not os.path.exists('./files/'+title):
    os.makedirs('./files/'+title)

if not os.path.isfile('./files/'+title+'/'+title+'.txt'):
	open('./files/'+title+'/'+title+'.txt', 'a')

# #Create the kind of deriv in the item-title folder
for i in range(number_of_captures):
	with open('./files/'+title+'/'+title+'.txt', 'a') as myfile:
		myfile.write(captures[i]+'\n')
	i+=1