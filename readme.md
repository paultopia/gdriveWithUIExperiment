Getting gdrive oauth to work in raw swift.  End state: an app that can select a word file, send it up to google drive, and re-download it as pdf. 

Steps: 

1.  Sign up for google drive API access.  It's a tiny bit unclear from the docs, but it seems to be: go to the [Google API console](https://console.developers.google.com/), click on credentials, and then click on create credentials, and then select "other."  Save the client ID and secret.  You may also have to go back to the main console screen and select "enable APIs and services," search for the drive API, and enable it.  Maybe. Also, you might have to do this from the context of a "project."

See general instructions for the oauth flow [here](https://developers.google.com/identity/protocols/OAuth2InstalledApp#overview). 

It looks like there are two basic ways to have the oauth flow call back into an app once users have authorized it: either spin up a web server on localhost, or set up a custom url scheme. The google docs are highly unclear as to how to give it the correct address to talk to either way---it looks like there should be a place to do so, but I can't find it.

2.  Tutorial for setting up a custom url scheme: [this looks good](https://css-tricks.com/create-url-scheme/).  I used `pgexperiment` as the URI scheme, so it should be possible to go to, e.g., `pgexperiment://foo.bar` in a browser and get input into the app. 
