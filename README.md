# brightsign-contest-beacon
This project is a demonstration BrightSign presentation with an iOS app that uses an iBeacon to notify nearby visitors to register for a contest.

If you have issues, questions, or suggestions, please post them on the <a href="https://github.com/brightsign/brightsign-contest-beacon/issues">Issues page</a> for this Github project.

Implementation details and notes will be provided on the project <a href="https://github.com/brightsign/brightsign-contest-beacon/wiki">Wiki page.</a>

Pull requests are welcome!

### Requirements and Tools
##### iOS app
The iOS app is written in Swift 3.0 and was developed using XCode 8.2. It is recommended to use this toolset to modify or extend the app.
To build the iOS app and test it on an iOS device, you must have an Apple developer account and you must create provisioning information based on your Apple developer account. Specifically, you should make the following modifications on the _General_ tab of the project page for the iosApp project in XCode:
* The project bundle identifier is currently set to _"com.myCompany.BleCommands"_. It is recommended to change this to reflect your organization domain.
* The team setting (for code signing) is set to _"None"_. You must specify the name of your Apple Development team in order to code sign the app for test deployment to an iOS device. See Apple developer documentation for more information.

##### BrightSign presentation
The BrightSign presentation has been authored using the current version of BrightAuthor 4.6.0.18.

The presentation is very simple. An iBeacon is defined as aprt of the presentation which is started as soon as the presentation starts. This is the iBeacon that the iOS app uses to determine when it is near the BrightSign player.

For the current implementation, the content is a simple LiveText display. In a real-world use case, the presentation content can be any type of presentation as dictated by the use case requirements.

### Presentation and App Overview
This presentation and app is a generic version of the demo that was presented at the BrightSign booth at the Infocomm 2016 trade show.

Prospective attendees to that show were invited to download a similar app from the Apple App Store prior to attending the show. (Attendees could also download the app while at the show.) Upon opening the app, a message is displayed in the app inviting the attendee to register for a contest, and then to visit the BrightSign booth to see the BrightBeacon demo. When the attendee visits the demo, they are automatically entered into the contest in which a random daily drawing was made for a prize.

The beacon is used to determine when the attendee visited the demo, and also to coordinate location specific messaging within the app.

When the app is first started, the user is asked for permission to use the iPhone location. If permission is granted, iOS scans for the beacon, on behalf of the app, at all times, whether or not the app is running.

When the attendee enters the region where the beacon can be detected, if the app is not running, the user will recieve a notification alert that says "Welcome to BrightSign." The attendee can then touch the notification to open the app.

When the app is open, the message presented depends on the attendee's proximity to the beacon, and also whether or not the attendee has registered for the contest. If they have not registered, they are encouraged to do so.

Upon registering, the contact information supplied is uploaded to a separate contest server. (Note: in this version of the demo, all contest server upload code has been disabled for simplification purposes. For more information on this aspect, see the notes below about the Networking components.)

When the attendee gets close to the trade show booth, a message is displayed indicating that they are close to the demo, and encouraging them to come closer.

When the attendee gets into closer proximity to the demo (within about 3 meters,) another message is displayed indicating that they have been automatically entered into the contest. A message is also sent to the contest server at this point to indicate that the attendee has visited the demo site, and their contact record is added to the contest eligibility pool.

### Notes on networking components
In the original demo, we set up a backend server to collect and manage attendee contact info data and the contest. All interaction with this _contest server_ is handled in the file _ContestManager.swift_. To implement server communication, we used the very popular Swift based HTTP networking package, <a href="https://github.com/Alamofire/Alamofire">_Alamofire_</a>.

We included this in our project using the _Cocoapods_ package manager.

The _ContestManager.swift_ file makes a single call using Alamofire to update the server. In this version of the demo, the base URL is a dummy string, and the Alamofire code has been commented out. This has been done to make this example simpler, and allow you to build the app without having to install Cocoapods and Alamofire.

See the <a href="https://github.com/Alamofire/Alamofire">Alamofire Github repository</a> for more information on Alamofire. There are links there that also describe how to add Alamofire to your project using Cocoapods. We have included a Podfile for this project that is written to install Alamofire, for those who might wish to experiment with this.

We do not, at this time, have an example of the Contest Server. It was a fairly simple web server and database that exposed a REST API.
