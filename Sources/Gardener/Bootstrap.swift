//
//  Bootstrap.swift
//  
//
//  Created by Dr. Brandon Wiley on 12/9/20.
//

import Foundation

public class Bootstrap
{
    static public func bootstrap(username: String, host: String, port: Int? = nil, source: String, branch: String = "main", target: String? = nil) -> Bool
    {
        guard let swiftURL = URL(string: "https://swift.org/builds/swift-5.3.1-release/ubuntu1804/swift-5.3.1-RELEASE/swift-5.3.1-RELEASE-ubuntu18.04.tar.gz") else {return false}
        let swiftDirName = "swift-5.3.1-RELEASE-ubuntu18.04"
        let swiftTarName = "swift-5.3.1-RELEASE-ubuntu18.04.tar.gz"
        let swiftDigest = "ab35646683aaf950f5c875d3ece94f596dcc079e"
        let swiftVersion = "Swift version 5.3.1 (swift-5.3.1-RELEASE)"

//        guard let swiftURL = URL(string: "https://swift.org/builds/swift-5.3.1-release/ubuntu2004/swift-5.3.1-RELEASE/swift-5.3.1-RELEASE-ubuntu20.04.tar.gz") else {return false}
//        let swiftDirName = "swift-5.3.1-RELEASE-ubuntu20.04"
//        let swiftTarName = "swift-5.3.1-RELEASE-ubuntu20.04.tar.gz"
//        let swiftDigest = "68eed7163bff480221ecfb71224aae334be2feff"
//        let swiftVersion = "Swift version 5.3 (swift-5.3-RELEASE)"

        guard let ssh = SSH(username: username, host: host, port: port) else {return false}

        if ssh.swiftVersion(path: "/root/\(swiftDirName)/usr/bin") != swiftVersion
        {
            ssh.download(url: swiftURL, outputFilename: swiftTarName, sha1sum: swiftDigest)

            if ssh.fileExists(path: swiftDirName)
            {
                ssh.rm(path: swiftDirName, force: true)
            }
            ssh.untargzip(path: swiftTarName)

            ssh.append(path: ".bashrc", string: "export PATH=\"${PATH}:/root/\(swiftDirName)/usr/bin\"")

            guard ssh.swiftVersion(path: "/root/\(swiftDirName)/usr/bin") == swiftVersion else {return false}
        }

        guard let sourceURL = URL(string: source) else {return false}
        ssh.gitClone(source: sourceURL, branch: branch)

        let package = sourceURL.lastPathComponent
        let installer: String = target ?? "\(package)Installer"
        ssh.swiftRun(path: package, target: installer)

        return true
    }
}
