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
let dependencies: [TargetDependency] = [ .project(target: "RadioBrowser", path: .relativeToRoot("Projects/RadioBrowser")) ]

let targets = Project.makeAppTargets(name: name,
                                     bundleIdPredix: bundleIdPrefix,
                                     platform: .iOS,
                                     dependencies: dependencies)
let project = Project(name: name,
                      organizationName: organization,
                      targets: targets)
