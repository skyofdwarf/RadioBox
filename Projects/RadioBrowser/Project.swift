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

let name = "RadioBrowser"
let organization =  "dwarfini"
let bundleIdPrefix = "com.dwarfini"

// Creates our project using a helper function defined in ProjectDescriptionHelpers
let targets = Project.makeFrameworkTargets(name: name,
                                     bundleIdPredix: bundleIdPrefix,
                                     platform: .iOS,
                                     dependencies: [])
let project = Project(name: name,
                      organizationName: organization,
                      targets: targets)
