# Khulnasoft Swift client

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkhulnasoft%2Fkhulnasoft-swift%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/khulnasoft/khulnasoft-swift)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkhulnasoft%2Fkhulnasoft-swift%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/khulnasoft/khulnasoft-swift)

This is a Swift client for [Khulnasoft].
It lets you run models from your Swift code,
and do various other things on Khulnasoft.

To learn how to use it,
[take a look at our guide to building a SwiftUI app with Khulnasoft](https://khulnasoft.com/docs/get-started/swiftui).

## Usage

Grab your API token from [khulnasoft.com/account](https://khulnasoft.com/account)
and pass it to `Client(token:)`:

```swift
import Foundation
import Khulnasoft

let khulnasoft = Khulnasoft.Client(token: <#token#>)
```

> [!WARNING]
> Don't store secrets in code or any other resources bundled with your app.
> Instead, fetch them from CloudKit or another server and store them in the keychain.

You can run a model and get its output:

```swift
let output = try await khulnasoft.run(
    "stability-ai/stable-diffusion-3",
    ["prompt": "a 19th century portrait of a gentleman otter"]
) { prediction in
    // Print the prediction status after each update
    print(prediction.status)
}

print(output)
// ["https://khulnasoft.delivery/yhqm/bh9SsjWXY3pGKJyQzYjQlsZPzcNZ4EYOeEsPjFytc5TjYeNTA/R8_SD3_00001_.webp"]
```

Or fetch a model by name and create a prediction against its latest version:

```swift
let model = try await khulnasoft.getModel("stability-ai/stable-diffusion-3")
if let latestVersion = model.latestVersion {
    let prompt = "a 19th century portrait of a gentleman otter"
    let prediction = try await khulnasoft.createPrediction(version: latestVersion.id,
                                                       input: ["prompt": "\(prompt)"],
                                                       wait: true)
    print(prediction.id)
    // "s654jhww3hrm60ch11v8t3zpkg"
    print(prediction.output)
    // ["https://khulnasoft.delivery/yhqm/bh9SsjWXY3pGKJyQzYjQlsZPzcNZ4EYOeEsPjFytc5TjYeNTA/R8_SD3_00001_.webp"]
}
```

Some models,
like [tencentarc/gfpgan](https://khulnasoft.com/tencentarc/gfpgan),
receive images as inputs.
To run a model that takes a file input you can pass either
a URL to a publicly accessible file on the Internet
or use the `uriEncoded(mimeType:) helper method to create
a base64-encoded data URL from the contents of a local file.

```swift
let model = try await khulnasoft.getModel("tencentarc/gfpgan")
if let latestVersion = model.latestVersion {
    let data = try! Data(contentsOf: URL(fileURLWithPath: "/path/to/image.jpg"))
    let mimeType = "image/jpeg"
    let prediction = try await khulnasoft.createPrediction(version: latestVersion.id,
                                                       input: ["img": "\(data.uriEncoded(mimeType: mimeType))"])
    print(prediction.output)
    // ["https://khulnasoft.delivery/mgxm/85f53415-0dc7-4703-891f-1e6f912119ad/output.png"]
}
```

You can start a model and run it in the background:

```swift
let model = khulnasoft.getModel("kvfrans/clipdraw")

let prompt = "watercolor painting of an underwater submarine"
var prediction = khulnasoft.createPrediction(version: model.latestVersion!.id,
                                         input: ["prompt": "\(prompt)"])
print(prediction.status)
// "starting"

try await prediction.wait(with: khulnasoft)
print(prediction.status)
// "succeeded"
```

You can cancel a running prediction:

```swift
let model = khulnasoft.getModel("kvfrans/clipdraw")

let prompt = "watercolor painting of an underwater submarine"
var prediction = khulnasoft.createPrediction(version: model.latestVersion!.id,
                                            input: ["prompt": "\(prompt)"])
print(prediction.status)
// "starting"

try await prediction.cancel(with: khulnasoft)
print(prediction.status)
// "canceled"
```

You can list all the predictions you've run:

```swift
var predictions: [Prediction] = []
var cursor: Khulnasoft.Client.Pagination<Prediction>.Cursor?
let limit = 100

repeat {
    let page = try await khulnasoft.getPredictions(cursor: cursor)
    predictions.append(contentsOf: page.results)
    cursor = page.next
} while predictions.count < limit && cursor != nil
```

## Adding `Khulnasoft` as a Dependency

To use the `Khulnasoft` library in a Swift project,
add it to the dependencies for your package and your target:

```swift
let package = Package(
    // name, platforms, products, etc.
    dependencies: [
        // other dependencies
        .package(url: "https://github.com/khulnasoft/khulnasoft-swift", from: "0.24.0"),
    ],
    targets: [
        .target(name: "<target>", dependencies: [
            // other dependencies
            .product(name: "Khulnasoft", package: "khulnasoft-swift"),
        ]),
        // other targets
    ]
)
```

[Khulnasoft]: https://khulnasoft.com
