import ProjectDescription
import ProjectDescriptionHelpers
import MyPlugin

/*
                +-------------+
                |             |
                |     App     | Contains RadioBox App target and RadioBox unit-test target
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

let name = "RadioBox"
let organization =  "dwarfini"
let bundleIdPrefix = "com.dwarfini"

// Creates our project using a helper function defined in ProjectDescriptionHelpers
let dependencies: [TargetDependency] = [
    .project(target: "RadioBrowser", path: .relativeToRoot("Projects/RadioBrowser")),
    .package(product: "Stevia"),
    .package(product: "SnapKit"),
    .package(product: "Kingfisher"),
    .package(product: "Then"),
    .package(product: "RDXVM"),
]

let targets = Project.makeAppTargets(name: name,
                                     bundleIdPredix: bundleIdPrefix,
                                     platform: .iOS,
                                     dependencies: dependencies)
let project = Project(name: name,
                      organizationName: organization,
                      packages: [
                        .package(url: "https://github.com/freshOS/Stevia", from: "5.1.0"),
                        .package(url: "https://github.com/SnapKit/SnapKit", from: "5.6.0"),
                        .package(url: "https://github.com/onevcat/Kingfisher", from: "7.0.0"),
                        .package(url: "https://github.com/devxoul/Then", from: "2.0.0"),
                        .package(url: "https://github.com/skyofdwarf/RDXVM", .branch("develop"))
                      ],
                      targets: targets)
