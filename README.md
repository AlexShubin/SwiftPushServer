
# Push notification server built with perfect server.

    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat" alt="Swift 3.0">
    </a>
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Platforms-OS%20X%20%7C%20Linux%20-lightgray.svg?style=flat" alt="Platforms OS X | Linux">
    </a>
    <a href="http://perfect.org/licensing.html" target="_blank">
        <img src="https://img.shields.io/badge/License-Apache-lightgrey.svg?style=flat" alt="License Apache">
    </a>
    <a href="https://codebeat.co/projects/github-com-perfectlysoft-perfect" target="_blank">
        <img src="https://codebeat.co/badges/85f8f628-6ce8-4818-867c-21b523484ee9" alt="codebeat">
    </a>
    <a href="http://twitter.com/PerfectlySoft" target="_blank">
        <img src="https://img.shields.io/badge/Twitter-@PerfectlySoft-blue.svg?style=flat" alt="PerfectlySoft Twitter">
    </a>
    <a href="http://perfect.ly" target="_blank">
        <img src="http://perfect.ly/badge.svg" alt="Slack Status">
    </a>

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

## Author

Alex Shubin

## License

Simplify is available under the MIT license. See the LICENSE file for more info.
