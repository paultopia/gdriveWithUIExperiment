# google drive oauth in swift: a demo/experiment.

Just an experiment in getting gdrive oauth to work in raw swift.  Partly because this is a thing that I want to do at some point in the near future for an actual app so I needed to figure out how.  Partly because google's documentation is frankly terrible and sooner or later I want to turn this into a tutorial so other humans can actually do it without spending hours searching stackoverflow answers and reading docs hidden in bizarre and obscure places.

## Current status

Works.  Ugly.

To be specific successfully going through oauth process with no library assistance beyond what's built into swift.  UI goes step by step, i.e. get a client code and put it into the first box, then click the first button to save it.  second button throws up an authorization request into safari and receives a temporary access code in response.  third button trades that access code in for a token.  all working.

I stuck a box on the right to actually just enter an auth token received from earlier testing (and copy-pasted from print) but it doesn't seem to be doing much.  So probably ignore that. 

I have, however, tested actual use of a token received in the same session, and it's working---the bottom middle test button currently sends a request for the metadata for the last created file in drive, and successfully receives a correct response.  So this thing is officially working.

Next steps: write up as a tutorial, clean up all the hacks (like the step by step button pressing as opposed to just doing the whole oauth flow in a single action, error handling rather than forcing everything and crashing if it doesn't work, )


## notes

**Signing up for google drive API access.****  It's a tiny bit unclear from the docs, but it seems to be: go to the [Google API console](https://console.developers.google.com/), click on credentials, and then click on create credentials, and then select "other."  Save the client ID and secret.  You may also have to go back to the main console screen and select "enable APIs and services," search for the drive API, and enable it.  Maybe. Also, you might have to do this from the context of a "project."  

See general instructions for the oauth flow [here](https://developers.google.com/identity/protocols/OAuth2InstalledApp#overview). 



It looks like there are two basic ways to have the oauth flow call back into an app once users have authorized it: either spin up a web server on localhost, or set up a custom url scheme. In order to make this work, you have to tell the credential requesty-thing that you're making an IOS app, and then the bundle id needs to be the same as the custom protocol for your uri scheme.

**Creating a custom url scheme** [this is a good tutorial](https://css-tricks.com/create-url-scheme/).  I used `io.gowder.experiment` as the URI scheme, so it should be possible to go to, e.g., `io.gowder.experiment://foo.bar` in a browser (works in safari at least, chrome has the nasty habit of interpreting it as a search** and get input into the app.   It has to have dots in it.  I just use same thing for bundle identifier and for uri scheme.

**url scheme and registration** the last two notes interact with one another.  The best process seems to be create a new project in google's interface, activate the drive API, create credentials (telling it what scopes you want to use), and generate credentials for an ios device.  give it your bundle ID in the one required field, and make that *both* your bundle idea and your custom url scheme protocol---so, like, for me, everything is io.gowder.experiment.  *Everything.*  Make note of your client key.

Then put your key into the nice spot on the application designated for that purpose.  Where it will be stored in [user defaults](https://developer.apple.com/documentation/foundation/userdefaults) even though apparently [that's insecure](https://medium.com/swift2go/application-security-musts-for-every-ios-app-dabf095b9c4f)?  works for experimentation tho.

**Making network requests** In order to make network requests, make sure that the sandbox is turned on and it's set to make outgoing connections.  I'm not sure if this happens automatically when you clone the xcode project (is this something turned on in info.plist?  WHO KNOWS!). [see also](https://stackoverflow.com/a/49892564/4386239).  For those of you who are, like me, not really big fans of the hyper-complicated xcode interface, you do this by clicking the name of your project at the very top of the thingey on the left, and then clicking capabilities, and it should all be in there.  (Incidentally, that's also where you do the stuff for custom url scheme, only instead of capabilities, use info.)

**actually presenting permission request to the user** when you google to present an authorization page to a user, rather than being sensible and sending you a custom url or something, it just sends you a pile of HTML to display. It also [blocks embedded webviews](https://developers.googleblog.com/2016/08/modernizing-oauth-interactions-in-native-apps.html).  So the only thing I could think to do was save the heml to a temporary file and then spawn it in safari (choosing safari in particular because when I did experiments, chrome seemed to choke on custom url schemes with dots in it, and google for some bizarre reason requires a custom url scheme with dots---FFS google).  So this is a hack, and also it leaves the browser window lingering around after the fact but whev.

**actually making requests** For some bizarre reason, the first request to the API in the oauth process is a get request. The second is a post request. Importantly (and undocumented), the `redirect_uri` has to be identical for each.  Actual API calls after the fact seem to be get requests, and you can either pass the access token in the headers with `Authorization: Bearer <access_token>` or pass it as part of a query string as `access_token=<access_token>`.  Naturally, the documentation only actually gives you this information in a [totally random, buried, place](https://developers.google.com/identity/protocols/OAuth2ServiceAccount**, because most of the auth docs assume you're just going to be using one of their helper libraries. 

**random swift/xcode** 

- Parsing JSON is lovely with `Codeable`.  Here's a [tutorial](https://benscheirman.com/2017/06/swift-json/).  I've been terrified of parsing JSON in languages with serious types for a long time, but this took me only marginally more typing than it would with python, and with less thinking.  Someone send cookies and chocolate to whoever proposed that protocol please. 

- Xcode is unlovely in the extreme. Random errors seem to crop up on the regular where some decision you made the last time you made the app stick around despite changing in the code/settings (for me in this process the most notable example was the custom uri not changing when I realized it needed dots). The solution generally is the menu incantation Product -> Clean Build Folder.  (Also, for some stupid reason, to actually get an executable to save somewhere in order to run it the menu incantation is Product -> Archive.  NOT any of the actual "build** options.  Which makes no sense whatsoever. Archive means build, build means some other kind of janky build that gives you no, you know, actual built artifact that you can use.**

**sending files up to drive** (in progress, working notes being sketched here.)

- multipart uploads are one option.  but implementing seems super complicated, and I don't really have a clue how to do it.  I started a stub for this and am working on building it out.  For future reference [one tutorial in swift 3](https://newfivefour.com/swift-form-data-multipart-upload-URLRequest.html), and [someone's gist](https://gist.github.com/nolanw/dff7cc5d5570b030d6ba385698348b7c), and [an old SO on the subject](https://stackoverflow.com/questions/29623187/upload-image-with-multipart-form-data-ios-in-swift) [and another SO on the subject](https://stackoverflow.com/questions/26162616/upload-image-with-parameters-in-swift/26163136#26163136).  The basic process seems to involve creating a boundary and passing it in a header (?) and then effectively constructing multiple request bodies on either side (?).  The google API also asks for the total size of the request, and I confess I'm not quite sure how to calculate that... like, add the file size to the size of a utf-8 encoded string with the rest of the body?! (But I guess the [httpBody](https://developer.apple.com/documentation/foundation/urlrequest/2011390-httpbody) of a urlrequest is just a `Data` so I could just grab the size of the whole thing right before sending?? )

- the resumable upload doesn't seem to demand multipart uploads, so it's a bit less complicated... may switch to that.



**a couple of other useful references**

- [google's explanation of the oauth steps](https://developers.google.com/identity/protocols/OAuth2InstalledApp) 

- [good networking in swift tutorial](https://medium.com/swift2go/networking-in-swift-the-right-way-17cd34d11b7b)

- [google docs for uploading](https://developers.google.com/drive/api/v3/manage-uploads)

- [google docs for uploading part 2](https://developers.google.com/drive/api/v3/reference/files)

