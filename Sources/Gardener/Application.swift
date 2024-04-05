//
//  File.swift
//  
//
//  Created by Dr. Brandon Wiley on 12/7/20.
//
#if os(iOS) || os(watchOS) || os(tvOS)
#else
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

    static public func installFromSource(path: String, language: Language, source: URL, branch: String) throws
    {
        let git = Git()
        let _ = File.cd(path)
        let clonePath = source.absoluteString
        let packageName = source.deletingPathExtension().lastPathComponent

        print(FileManager.default.currentDirectoryPath)

        if File.exists(packageName)
        {
            print(FileManager.default.currentDirectoryPath)
            let _ = File.cd(packageName)
            try git.checkout(branch)
            try git.pull("origin", branch)
        }
        else
        {
            let _ = git.clone(clonePath)
            let _ = File.cd(packageName)
        }

        switch language
        {
            case .go:
                let go = Go()
                let _ = go.build()
            case .swift:
                guard let swift = SwiftTool() else {return}
                let _ = swift.build()
        }
    }
}
#endif
