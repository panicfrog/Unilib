## Description

#### This experimental demo, built on the Moonbit language, allows Moonbit code to run on iOS platforms. You can execute the same logic using native (C) or JavaScript, enabling a foundation for native hot reload functionality.

## How to use it



### 1. build xcframwork

```shell
./build_xcframework.sh
```

### 2. drop Unilib.xcframework to your xcode project

### 3. Call the exported function

- init moonbit lib

```swift
import UIKit
import Unilib

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // init moonbit lib
        moonbit_init()
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}
```

- call function

```swift
import Foundation
import Unilib
import JavaScriptCore

var CALL_FROM_NATIVE = true

func callGreeting(context: JSContext) {
  // call native function
    if CALL_FROM_NATIVE {
        let c_str = greeting_native_cstr()
        guard let pointer = c_str else { return }
        defer {
            moonbit_decref(UnsafeMutablePointer(mutating: c_str))
        }
        let str = String(cString: pointer)
        print("greeting_native() 结果：\(str)")
    } else {
      // call javascript function
        if let exports = context.objectForKeyedSubscript("exports"),
           let greetingFunc = exports.objectForKeyedSubscript("greeting") {
            let result = greetingFunc.call(withArguments: [])
            print("greeting_js() 结果: \(result?.toString() ?? "")")
        }
    }
}

```

