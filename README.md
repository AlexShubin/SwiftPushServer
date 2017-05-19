
# Push notification server built with perfect server.

Sends pushes both on iOS and Android. Web interface and post-request API availible.

# Installation

## Just to run on linux or mac

in project directory:

$ swift build

Then you can run it by 

$ .build/debug/SwiftPushServer

## On OSx to Open and Run in XCode

Generate XCode project:

$ swift package generate-xcodeproj

change scheme to executable, then go to "edit sceme"->"options" and set custom working directory to your project dir

And then run it from XCode

[![License](https://img.shields.io/cocoapods/l/Simplify.svg?style=flat)]
[![Platform](https://img.shields.io/cocoapods/p/Simplify.svg?style=flat)]

## Author

Alex Shubin

## License

Simplify is available under the MIT license. See the LICENSE file for more info.
