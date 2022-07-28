//
//  Homebrew.swift
//

import Foundation
import Datable

public class Homebrew
{
    static public func update() -> (Int32, String, String)?
    {
        let command = Command()
        command.addPath("/opt/homebrew/bin")
        guard let (exitCode, data, errData) = command.run("brew", "update") else {return nil}

        return (exitCode, data.string, errData.string)
    }

    static public func upgrade() -> (Int32, String, String)?
    {
        let command = Command()
        command.addPath("/opt/homebrew/bin")
        guard let (exitCode, data, errData) = command.run("brew", "upgrade") else {return nil}

        return (exitCode, data.string, errData.string)
    }

    static public func install(_ package: String) -> (Int32, String, String)?
    {
        let command = Command()
        command.addPath("/opt/homebrew/bin")
        guard let (exitCode, data, errData) = command.run("brew", "install", package) else {return nil}

        return (exitCode, data.string, errData.string)
    }

    static public func remove(_ package: String) -> (Int32, String, String)?
    {
        let command = Command()
        command.addPath("/opt/homebrew/bin")
        guard let (exitCode, data, errData) = command.run("brew", "remove", package) else {return nil}

        return (exitCode, data.string, errData.string)
    }

    static public func isInstalled(_ package: String) -> Bool?
    {
        let command = Command()
        command.addPath("/opt/homebrew/bin")
        guard let (exitCode, data, errData) = command.run("brew", "list", package) else {return nil}

        return exitCode == 0
    }
}
