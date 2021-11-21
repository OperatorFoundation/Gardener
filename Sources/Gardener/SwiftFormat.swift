//
//  SwiftFormat.swift
//  
//
//  Created by Dr. Brandon Wiley on 11/21/21.
//

import Foundation

public class SwiftFormat
{
    static let command = Command()

    public static func install()
    {
        guard let installed = Homebrew.isInstalled("swiftformat") else {return}
        if !installed
        {
            let _ = Homebrew.install("swiftformat")
        }
    }

    public static func reformat(_ path: String) -> Bool
    {
        guard let (exitCode, _, _) = SwiftFormat.command.run("swiftformat", path) else {return false}
        return exitCode == 0
    }
}
