import ProjectDescription
import ProjectDescriptionHelpers
import MyPlugin

/*
                +-------------+
                |             |
                |     App     | Contains Radiow App target and Radiow unit-test target
                |             |
         +------+-------------+-------+
         |         depends on         |
         |                            |
 +----v-----+                   +-----v-----+
 |          |                   |           |
 |   Kit    |                   |     UI    |   Two independent frameworks to share code and start modularising your app
 |          |                   |           |
 +----------+                   +-----------+

 */

// MARK: - Project

// Local plugin loaded
let localHelper = LocalHelper(name: "MyPlugin")

let name = "RadioBrowser"
let organization =  "dwarfini"
let bundleIdPrefix = "com.dwarfini"

let dependencies: [TargetDependency] = [
    .package(product: "Moya"),
    .package(product: "CombineMoya"),
]

// Creates our project using a helper function defined in ProjectDescriptionHelpers
let targets = Project.makeFrameworkTargets(name: name,
                                     bundleIdPredix: bundleIdPrefix,
                                     platform: .iOS,
                                     dependencies: dependencies)
let project = Project(name: name,
                      organizationName: organization,
                      packages: [
                        .package(url: "https://github.com/Moya/Moya", from: "15.0.0")
                      ],
                      targets: targets)
