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
let appVersion = "1.0.0"
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

let scripts: [TargetScript] = [
    .pre(script: """
#!/usr/bin/env bash

epoch=`date +'%s'`
app_version=\(appVersion)
#app_version=`sed -n -E '/CFBundleShortVersionString/{n;s/.*<string>(.*)<\\/string>.*$/\\1/p;}' ${PROJECT_DIR}/${INFOPLIST_FILE}`

echo info plist: ${PROJECT_DIR}/${INFOPLIST_FILE}
echo epoch: $epoch
echo app version: $app_version

sed -i -n -E "/CFBundleVersion/{n;s/<string>(.*)<\\/string>/<string>$app_version.$epoch<\\/string>/;}" ${PROJECT_DIR}/${INFOPLIST_FILE}
""",
         name: "Update Bundle Version",
         basedOnDependencyAnalysis: false
        )
]

let targets = Project.makeAppTargets(name: name,
                                     appVersion: .string(appVersion),
                                     bundleIdPredix: bundleIdPrefix,
                                     platform: .iOS,
                                     scripts: scripts,
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
