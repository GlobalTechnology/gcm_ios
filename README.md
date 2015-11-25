### GCM App

Requirements
---
The project uses Swift 1.2. You will need to install Xcode 6.4 (It is the latest version of Xcode that builds Swift 1.2) - Download from the [Apple Developer Archives](https://developer.apple.com/downloads/)

[Cocoapods](www.cocoapods.org)
```shell
gem install cocoapods
pod setup
pod repo add globaltechnology https://github.com/GlobalTechnology/cocoapods-specs.git 
```

To Develop
---
```shell
pod install
open gcmapp.xcworkspace
```

>There is a config.plist file that you will need to request from us (containing private keys)
