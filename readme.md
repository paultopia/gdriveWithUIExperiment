Getting gdrive oauth to work in raw swift.  End state: an app that can select a word file, send it up to google drive, and re-download it as pdf. 

**Current status**: successfully going through oauth process with no library assistance beyond what's built into swift.  UI goes step by step, i.e. get a client code and put it into the first box, then click the first button to save it.  second button throws up an authorization request into safari and receives a temporary access code in response.  third button trades that access code in for a token.  all working.

bottom middle button currently doesn't do anything.  it's my working test button where I just put whatever code I'm working on in. 

next steps: test to make sure actual API access works using the code I have.  then it'll be done and officially working.  but really, getting through oauth itself is a major chore.

**notes**: 

1.  Sign up for google drive API access.  It's a tiny bit unclear from the docs, but it seems to be: go to the [Google API console](https://console.developers.google.com/), click on credentials, and then click on create credentials, and then select "other."  Save the client ID and secret.  You may also have to go back to the main console screen and select "enable APIs and services," search for the drive API, and enable it.  Maybe. Also, you might have to do this from the context of a "project."

See general instructions for the oauth flow [here](https://developers.google.com/identity/protocols/OAuth2InstalledApp#overview). 

It looks like there are two basic ways to have the oauth flow call back into an app once users have authorized it: either spin up a web server on localhost, or set up a custom url scheme. In order to make this work, you have to tell the credential requesty-thing that you're making an IOS app, and then the bundle id needs to be the same as the custom protocol for your uri scheme.

2.  Tutorial for setting up a custom url scheme: [this looks good](https://css-tricks.com/create-url-scheme/).  I used `io.gowder.experiment` as the URI scheme, so it should be possible to go to, e.g., `io.gowder.experiment://foo.bar` in a browser (works in safari at least, chrome has the nasty habit of interpreting it as a search) and get input into the app.   It has to have dots in it.  I just use same thing for bundle identifier and for uri scheme.

3.  Put your key into the nice spot on the application designated for that purpose.  Where it will be stored in [user defaults](https://developer.apple.com/documentation/foundation/userdefaults) even though apparently that's insecure?  works for experimentation tho.

4.  In order to make network requests, make sure that the sandbox is turned on and it's set to make outgoing connections.  I'm not sure if this happens automatically when you clone the xcode project (is this something turned on in info.plist?  WHO KNOWS!). [see also](https://stackoverflow.com/a/49892564/4386239).

5.  Since google oauth doesn't allow embedded webviews, I'm using a hack where I take the html that the authorization request gets back from google, saving it to a temp file, and spawning a full-fledged safari instance to handle it.  

6.  parsing JSON is lovely with `Codeable`.

7.  For some bizarre reason, the first request to the API is a get request. The secon is a post request. Importantly (and undocumented), the `redirect_uri` has to be identical for each.
