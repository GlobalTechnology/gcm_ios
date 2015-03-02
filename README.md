### GCM App
## To Develop
```shell
sudo gem install cocoapods
pod setup
pod repo add globaltechnology git@github.com:GlobalTechnology/cocoapods-specs.git 
pod install
open gcmapp.xcworkspace
```

>If you are struggling with the 3rd line (pod repo add...) - this may be becuase you do not have ssh keys tied to you github account. You can either install these using [these instructions](https://help.github.com/articles/generating-ssh-keys/). Alternatively, you can use https instead - by changing this line to:
```shell 
pod repo add globaltechnology https://github.com/GlobalTechnology/cocoapods-specs.git
```

>Finally, there is a config file that you will need to request from us (containing private keys)
