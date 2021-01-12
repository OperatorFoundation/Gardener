//
//  Bootstrap.swift
//  
//
//  Created by Dr. Brandon Wiley on 12/9/20.
//

import Foundation

public struct SwiftVersion
{
    public let url: URL
    public let dirName: String
    public let tarName: String
    public let digest: String
    public let versionString: String
    public let dependencies: [String]

    public init?(swiftVersion: String, ubuntuVersion: String, digest: String)
    {
        let ubuntuParts = ubuntuVersion.split(separator: ".")
        guard ubuntuParts.count == 2 else {return nil}
        let ubuntuMajor = ubuntuParts[0]
        let ubuntuMinor = ubuntuParts[1]
        let squishedUbuntuVersion = "\(ubuntuMajor)\(ubuntuMinor)"
        self.url = URL(string: "https://swift.org/builds/swift-\(swiftVersion)-release/ubuntu\(squishedUbuntuVersion)/swift-\(swiftVersion)-RELEASE/swift-\(swiftVersion)-RELEASE-ubuntu\(ubuntuVersion).tar.gz")!
        self.dirName = "swift-\(swiftVersion)-RELEASE-ubuntu\(ubuntuVersion)"
        self.tarName = "swift-\(swiftVersion)-RELEASE-ubuntu\(ubuntuVersion).tar.gz"
        self.digest = digest
        self.versionString = swiftVersion

        switch ubuntuVersion
        {
            case "16.04":
                self.dependencies = [
                    "install",
                    "binutils",
                    "git",
                    "libc6-dev",
                    "libcurl3",
                    "libedit2",
                    "libgcc-5-dev",
                    "libpython2.7",
                    "libsqlite3-0",
                    "libstdc++-5-dev",
                    "libxml2",
                    "pkg-config",
                    "tzdata",
                    "zlib1g-dev",
                ]
            case "18.04":
                self.dependencies = [
                    "install",
                    "binutils",
                    "git",
                    "libc6-dev",
                    "libcurl4",
                    "libedit2",
                    "libgcc-5-dev",
                    "libpython2.7",
                    "libsqlite3-0",
                    "libstdc++-5-dev",
                    "libxml2",
                    "pkg-config",
                    "tzdata",
                    "zlib1g-dev",
                ]
            case "20.04":
                self.dependencies = [
                    "binutils",
                    "git",
                    "gnupg2",
                    "libc6-dev",
                    "libcurl4",
                    "libedit2",
                    "libgcc-9-dev",
                    "libpython2.7",
                    "libsqlite3-0",
                    "libstdc++-9-dev",
                    "libxml2",
                    "libz3-dev",
                    "pkg-config",
                    "tzdata",
                    "zlib1g-dev",
                ]
            default:
                return nil
        }
    }
}

public class Bootstrap
{
    static public func getSwiftVersion(swiftVersion: String, ubuntuVersion: String) -> SwiftVersion?
    {
        switch (swiftVersion, ubuntuVersion)
        {
            case ("5.3.1", "18.04"):
                return SwiftVersion(
                    swiftVersion: swiftVersion,
                    ubuntuVersion: ubuntuVersion,
                    digest: "ab35646683aaf950f5c875d3ece94f596dcc079e"
                )
            case ("5.3.2", "18.04"):
                return SwiftVersion(
                    swiftVersion: swiftVersion,
                    ubuntuVersion: ubuntuVersion,
                    digest: "834ed9e1257e6884b5b6a229396f2e79d143a868"
                )
            case ("5.3.2", "20.04"):
                return SwiftVersion(
                    swiftVersion: swiftVersion,
                    ubuntuVersion: ubuntuVersion,
                    digest: "e8daf05ac2ee976958c91ab7b3b99fc9abebe06e"
                )
            default:
                return nil
        }
    }

    static public func bootstrap(username: String, host: String, port: Int? = nil, source: String, branch: String = "main", target: String? = nil, packages: [String]? = nil) -> Bool
    {
        guard let ssh = SSH(username: username, host: host, port: port) else {return false}

        guard let ubuntuVersion = ssh.lsb_release() else {return false}
        guard let swiftVersion = getSwiftVersion(swiftVersion: "5.3.2", ubuntuVersion: ubuntuVersion) else {return false}

        if ssh.swiftVersion(path: "/root/\(swiftVersion.dirName)/usr/bin") != swiftVersion.versionString
        {
            let _ = ssh.update()
            
            for dependency in swiftVersion.dependencies
            {
                let _ = ssh.install(package: dependency)
            }

            let _ = ssh.download(url: swiftVersion.url, outputFilename: swiftVersion.tarName, sha1sum: swiftVersion.digest)

            if ssh.fileExists(path: swiftVersion.dirName)
            {
                let _ = ssh.rm(path: swiftVersion.dirName, force: true)
            }
            let _ = ssh.untargzip(path: swiftVersion.tarName)

            let _ = ssh.append(path: ".bashrc", string: "export PATH=\"${PATH}:/root/\(swiftVersion.dirName)/usr/bin\"")

            let reportedVersion = ssh.swiftVersion(path: "/root/\(swiftVersion.dirName)/usr/bin")
            guard reportedVersion == swiftVersion.versionString
            else
            {
                print("\n Unable to continue:")
                print("\(reportedVersion ?? "nil") does not equal \(swiftVersion.versionString)")
                return false
            }
        }

        if let installPackages = packages
        {
            for installPackage in installPackages
            {
                let _ = ssh.install(package: installPackage)
            }
        }
        
        guard let sourceURL = URL(string: source) else {return false}
        let _ = ssh.gitClone(source: sourceURL, branch: branch)

        let package = sourceURL.lastPathComponent
        let installer: String = target ?? "\(package)Installer"
        let _ = ssh.swiftRun(path: package, target: installer, pathToSwift: "/root/\(swiftVersion.dirName)/usr/bin")

        return true
    }
}
