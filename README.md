RECOMMENDED INSTALLATION

-- Just to run on linux or mac

in project directory:

$ swift build

Then you can run it by 

$ .build/debug/SwiftPushServer

-- On OSx to Open and Run in XCode

Generate XCode project:

$ swift package generate-xcodeproj

change scheme to executable, then go to "edit sceme"->"options" and set custom working directory to your project dir

And then run it from XCode
