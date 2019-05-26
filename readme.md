# google drive oauth in swift: a demo/experiment.

Just an experiment in getting gdrive oauth to work in raw swift.  Partly because this is a thing that I want to do at some point in the near future for an actual app so I needed to figure out how.  Partly because google's documentation is frankly terrible and sooner or later I want to turn this into a tutorial so other humans can actually do it without spending hours searching stackoverflow answers and reading docs hidden in bizarre and obscure places.

## Current status

Works.  All oauth works, although it doesn't automatically go fetch a refresh token when the current one expires (you gotta hit a button for that).  Also, upload a word file as google docs works, and downloading the just-uploaded file as a pdf into a temp file works. 

--------

to actually use, put the client ID for an app with the appropriate scopes (see the function that kicks off the flow for what I'm using) then click the obvious button to authenticate.  It'll spawn a safari window to ask for permission.  Seems to successfully persist credentials in user defaults between builds.

Next steps: write up as a tutorial, clean up all the hacks (like the step by step button pressing as opposed to just doing the whole oauth flow in a single action, error handling rather than forcing everything and crashing if it doesn't work, )

--------

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

**uploading files** using multipart upload request.

Here are some resources:

- [one tutorial in swift 3](https://newfivefour.com/swift-form-data-multipart-upload-URLRequest.html)

- [someone's gist](https://gist.github.com/nolanw/dff7cc5d5570b030d6ba385698348b7c)

- [an old SO on the subject](https://stackoverflow.com/questions/29623187/upload-image-with-multipart-form-data-ios-in-swift) 

- [and another SO on the subject](https://stackoverflow.com/questions/26162616/upload-image-with-parameters-in-swift/26163136#26163136). 


After reading [this SO](https://stackoverflow.com/questions/611906/http-post-with-url-query-parameters-good-idea-or-not), I guess when google asks for a query parameter in a post request you just mush it into the string like a get request?  OKAY.... seems to work, not sure why, but ok. 

- Useful thing: swift will take care of adding the content-length header that google demands. So that's useful.

IDIOTIC thing: swift  doesn't let you set authentication headers directly?!!?  So, no clue how to set the standard bearer token authentication for this API in a header---it's really flat-out moronic.  The docs say to do a bunch of crazy stuff with classes and delegates to respond to an "[authentication challenge](https://developer.apple.com/documentation/foundation/url_loading_system/handling_an_authentication_challenge)"  Which I guess is a [recognized method of authenticating](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication) except... wait for it... **swift doesn't support this kind of authentication!!** 

That is, at least as of the end of 2017 [URLSession doesn't support bearer challenges](https://forums.developer.apple.com/thread/92429) ([seems to still be true judging from list of methods supported in docs](https://developer.apple.com/documentation/foundation/urlprotectionspace/nsurlprotectionspace_authentication_method_constants)).  Despite the fact that this is in the [oauth2 spec](https://tools.ietf.org/html/rfc6750#section-3)!!!   

Fortunately, google's API is kind enough to just let you pass the token in the query string instead of using a header.  So I'm just doing that.  Also, seriously considering dropping down to a low-level library like in objective-c, or even c, or using rust or something, that will actually let me SET THE DAMN HEADERS MYSELF at some point.  It's maddening that apple won't let you set authentication headers.

Bizarrely, even though the swift docs [specifically say they won't let you set reserved headers](https://developer.apple.com/documentation/foundation/urlrequest/2011522-addvalue) and [specifically say the authorization header is reserved](https://developer.apple.com/documentation/foundation/nsurlrequest#1776617), well,  [at least one oauth library does it anyway](https://github.com/p2/OAuth2/blob/26e6c2b0bf755986f18a98af1c8a3c2d5f511ee5/Sources/Base/extensions.swift#L99), so I guess it does work, just not reliably??!!


- https://forums.developer.apple.com/thread/68809

- https://stackoverflow.com/questions/56194203/swift-5-urlrequest-authorization-header-reserved-how-to-set 

- https://blog.cocoafrog.de/2017/11/18/how-nsurlsession-authentication-should-work.html

- https://stackoverflow.com/questions/44843404/how-to-set-a-token-xxxxxxxxxx-for-authorization-in-http-header-in-urlsession 

- https://stackoverflow.com/questions/46852680/urlsession-doesnt-pass-authorization-key-in-header-swift-4





**a couple of other useful references**

- [google's explanation of the oauth steps](https://developers.google.com/identity/protocols/OAuth2InstalledApp) 

- [good networking in swift tutorial](https://medium.com/swift2go/networking-in-swift-the-right-way-17cd34d11b7b)

- [google docs for uploading](https://developers.google.com/drive/api/v3/manage-uploads)

- [google docs for uploading part 2](https://developers.google.com/drive/api/v3/reference/files)

- [mime types for uploading](https://developers.google.com/drive/api/v3/mime-types)---you can, e.g, upload a word file in the google docs mime type and it'll convert it so you can call docs stuff on it/make use of download conversions/etc.

- [multipart uploads, in general](https://www.w3.org/TR/html401/interact/forms.html#h-17.13.4.2)


