import ProjectDescription

/// Project helpers are functions that simplify the way you define your project.
/// Share code to create targets, settings, dependencies,
/// Create your own conventions, e.g: a func that makes sure all shared targets are "static frameworks"
/// See https://docs.tuist.io/guides/helpers/

extension Project {
    /// Helper function to create a framework target and an associated unit test target
    public static func makeFrameworkTargets(name: String, bundleIdPredix: String, platform: Platform, dependencies: [TargetDependency]) -> [Target] {
        let sources = Target(name: name,
                platform: platform,
                product: .framework,
                bundleId: "\(bundleIdPredix).\(name)",
                deploymentTarget: .iOS(targetVersion: "14.0", devices: [.iphone, .ipad]),
                infoPlist: .default,
                sources: ["Sources/**"],
                resources: [],
                dependencies: dependencies)
        let tests = Target(name: "\(name)Tests",
                platform: platform,
                product: .unitTests,
                bundleId: "\(bundleIdPredix).\(name)Tests",
                deploymentTarget: .iOS(targetVersion: "14.0", devices: [.iphone, .ipad]),
                infoPlist: .default,
                sources: ["Tests/**"],
                resources: [],
                dependencies: [.target(name: name)])
        return [sources, tests]
    }

    /// Helper function to create the application target and the unit test target.
    public static func makeAppTargets(name: String, bundleIdPredix: String, platform: Platform, scripts: [TargetScript] = [], dependencies: [TargetDependency]) -> [Target] {
        let platform: Platform = platform
        let infoPlist: [String: InfoPlist.Value] = [
            "CFBundleShortVersionString": "1.0",
            "CFBundleVersion": "1",
            "UIMainStoryboardFile": "",
            "UILaunchStoryboardName": "LaunchScreen",
            "NSAppTransportSecurity": .dictionary(["NSAllowsArbitraryLoads": .boolean(true)])
            ]

        let mainTarget = Target(
            name: name,
            platform: platform,
            product: .app,
            bundleId: "\(bundleIdPredix).\(name)",
            deploymentTarget: .iOS(targetVersion: "14.0", devices: [.iphone, .ipad]),
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            scripts: scripts,
            dependencies: dependencies
        )

        let testTarget = Target(
            name: "\(name)Tests",
            platform: platform,
            product: .unitTests,
            bundleId: "\(bundleIdPredix).\(name)Tests",
            deploymentTarget: .iOS(targetVersion: "14.0", devices: [.iphone, .ipad]),
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "\(name)")
        ])
        return [mainTarget, testTarget]
    }
}
