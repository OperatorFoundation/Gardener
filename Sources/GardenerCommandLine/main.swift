//
//  main.swift
//  
//
//  Created by Dr. Brandon Wiley on 7/17/23.
//

import ArgumentParser
import Foundation

import Gardener

struct GardenerCommandLine: ParsableCommand
{
    static let configuration = CommandConfiguration(
        commandName: "gardener",
        subcommands: [Bootstrap.self]
    )
}

extension GardenerCommandLine
{
    struct Bootstrap: ParsableCommand
    {
        @Argument(help: "language runtime to bootstrap on remote server")
        var language: String

        @Argument(help: "version of Ubuntu running on the server")
        var ubuntuVersion: String

        @Argument(help: "IP address of server")
        var host: String

        mutating public func run() throws
        {
            guard let bootstrapLanguage = BootstrapLanguage(rawValue: language) else
            {
                throw GardenerCommandLineError.unsupportedLanguage(language)
            }

            switch bootstrapLanguage
            {
                case .swift:
                    try self.bootstrapSwift(host: host, ubuntuVersion: ubuntuVersion)
            }
        }

        func bootstrapSwift(host: String, ubuntuVersion: String) throws
        {
            guard let swiftVersion = SwiftVersion(swiftVersion: "5.8.1", ubuntuVersion: ubuntuVersion) else
            {
                throw GardenerCommandLineError.unsupportedSwiftUbuntuVersionCombination("5.8.1", ubuntuVersion)
            }

            try swiftVersion.bootstrap(username: "root", host: host)
        }
    }
}

public enum BootstrapLanguage: String
{
    case swift
}

GardenerCommandLine.main()

public enum GardenerCommandLineError: Error
{
    case unsupportedLanguage(String)
    case unsupportedSwiftUbuntuVersionCombination(String, String) // Swift version, Ubuntu version
}
