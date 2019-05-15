Getting gdrive oauth to work in raw swift.  End state: an app that can select a word file, send it up to google drive, and re-download it as pdf. 

Steps: 

1.  Sign up for google drive API access.  It's a tiny bit unclear from the docs, but it seems to be: go to the [Google API console](https://console.developers.google.com/), click on credentials, and then click on create credentials, and then select "other."  Save the client ID and secret.  You may also have to go back to the main console screen and select "enable APIs and services," search for the drive API, and enable it.  Maybe. Also, you might have to do this from the context of a "project."

See general instructions for the oauth flow [here](https://developers.google.com/identity/protocols/OAuth2InstalledApp#overview). 

It looks like there are two basic ways to have the oauth flow call back into an app once users have authorized it: either spin up a web server on localhost, or set up a custom url scheme. The google docs are highly unclear as to how to give it the correct address to talk to either way---it looks like there should be a place to do so, but I can't find it.

2.  Tutorial for setting up a custom url scheme: [this looks good](https://css-tricks.com/create-url-scheme/).  I used `io.gowder.experiment` as the URI scheme, so it should be possible to go to, e.g., `io.gowder.experiment://foo.bar` in a browser (works in safari at least, chrome has the nasty habit of interpreting it as a search) and get input into the app. 

3.  Put your key into the nice spot on the application designated for that purpose.  Where it will be stored in [user defaults](https://developer.apple.com/documentation/foundation/userdefaults) even though apparently that's insecure?  works for experimentation tho.

4.  In order to make network requests, make sure that the sandbox is turned on and it's set to make outgoing connections.  I'm not sure if this happens automatically when you clone the xcode project (is this something turned on in info.plist?  WHO KNOWS!). [see also](https://stackoverflow.com/a/49892564/4386239).

5.  Since google oauth doesn't allow embedded webviews, I'm rolling out a system where I take the html that the authorization request gets back from google, saving it to a temp file, and spawning a full-fledged safari instance to handle it.  

CURRENT STATUS: you can put a client ID in, and click a button to save that.  Then you can click a button to authorize access, and it'll spawn a web browser with the google auth request; if accepted that browser will then an auth code back to the app, which will receive it, parse it, and shove it into user defaults.  So I'm at [step 4 of these instructions](https://developers.google.com/identity/protocols/OAuth2InstalledApp#overview) 
