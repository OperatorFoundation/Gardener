//
//  Apt.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/2/20.
//

import Foundation
import Datable

public class Apt
{
    static public func update() -> (Int32, String)?
    {
        let command = Command()
        guard let (exitCode, data) = command.run("apt", "update", "-y") else {return nil}
        
        return (exitCode, data.string)
    }

    static public func upgrade() -> (Int32, String)?
    {
        let command = Command()
        guard let (exitCode, data) = command.run("apt", "upgrade", "-y") else {return nil}
        
        return (exitCode, data.string)
    }

    static public func autoremove() -> (Int32, String)?
    {
        let command = Command()
        guard let (exitCode, data) = command.run("apt", "autoremove", "-y") else {return nil}
        
        return (exitCode, data.string)
    }

    static public func fix() -> (Int32, String)?
    {
        let command = Command()
        guard let (exitCode, data) = command.run("apt", "install", "-y", "-f") else {return nil}
        
        return (exitCode, data.string)
    }
    
    static public func install(_ package: String) -> (Int32, String)?
    {
        let command = Command()
        guard let (exitCode, data) = command.run("apt", "install", "-y", package) else {return nil}
        
        return (exitCode, data.string)
    }
    
    static public func remove(_ package: String) -> (Int32, String)?
    {
        let command = Command()
        guard let (exitCode, data) = command.run("apt", "remove", "-y", package) else {return nil}
        
        return (exitCode, data.string)
    }
}
