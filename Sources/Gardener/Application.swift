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
        let _ = git.cd(path)
        let clonePath = source.absoluteString
        let packageName = source.deletingPathExtension().lastPathComponent

        print(FileManager.default.currentDirectoryPath)

        if File.exists(packageName)
        {
            print(FileManager.default.currentDirectoryPath)
            let _ = git.cd(packageName)
            let _ = git.checkout(branch)
            let _ = git.pull("origin", branch)
        }
        else
        {
            let _ = git.clone(clonePath)
            let _ = git.cd(packageName)
        }

        switch language
        {
            case .go:
                let go = Go()
                let _ = go.build()
            case .swift:
                let swift = Swift()
                let _ = swift.build()
        }
    }
}
