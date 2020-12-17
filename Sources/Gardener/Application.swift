//
//  File.swift
//  
//
//  Created by Dr. Brandon Wiley on 12/7/20.
//

import Foundation

import Foundation
import Datable

public enum Language
{
    case go
    case swift
}

public class Application
{
    // FIXME - better return types, parse the output
    static public func installFromPackage(package: String) -> (Int32, String, String)?
    {
        if Apt.installed(package)
        {
            return nil
        }
        else
        {
            return Apt.install(package)
        }
    }

    static public func installFromSource(path: String, language: Language, source: URL, branch: String)
    {
        let git = Git()
        git.cd(path)
        let clonePath = source.absoluteString
        var packageName = source.deletingPathExtension().lastPathComponent

        print(FileManager.default.currentDirectoryPath)

        if File.exists(packageName)
        {
            print(FileManager.default.currentDirectoryPath)
            git.cd(packageName)
            git.checkout(branch)
            git.pull("origin", branch)
        }
        else
        {
            git.clone(clonePath)
            git.cd(packageName)
        }

        switch language
        {
            case .go:
                let go = Go()
                go.build()
            case .swift:
                let swift = Swift()
                swift.build()
        }
    }
}
