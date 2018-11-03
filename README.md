
# Push notification server built with perfect server

<p>
<img src="https://img.shields.io/badge/Swift-4.2-orange.svg">
<img src="https://img.shields.io/badge/Platforms-OS%20X%20%7C%20Linux%20-lightgray.svg?style=flat">
<img src="https://img.shields.io/packagist/l/doctrine/orm.svg">
</p>

Sends pushes both on iOS and Android. Web interface and post-request API availible.

# Installation

## Just to run on linux or mac

in project directory:

$ swift build

Then you can run it by 

$ .build/debug/SwiftPushServer

Then print `localhost:8090` in your browser

## On OSx to Open and Run in XCode

Generate XCode project:

$ swift package generate-xcodeproj

change scheme to executable, then go to "edit sceme"->"options" and set custom working directory to your project dir

And then run it from XCode

Then print `localhost:8090` in your browser

## Author

Alex Shubin

## License

Swift push server is available under the MIT license.
