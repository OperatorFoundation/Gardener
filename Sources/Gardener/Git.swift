//
//  Git.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/2/20.
//

import Foundation

public class Git
{
    var command = Command()
    
    public init()
    {
        // Public initializer
    }
    
    public func initialize() -> (Int32, Data, Data)?
    {
        return command.run("git", "init")
    }

    public func clone(_ path: String) -> (Int32, Data, Data)?
    {
        return command.run("git", "clone", path)
    }

    public func checkout(_ branch: String) -> (Int32, Data, Data)?
    {
        return command.run("git", "checkout", branch)
    }
    
    public func pull(_ remote: String, _ branch: String) -> (Int32, Data, Data)?
    {
        return command.run("git", "pull", remote, branch)
    }
    
    public func push(_ remote: String, _ branch: String) -> (Int32, Data, Data)?
    {
        return command.run("git", "push", remote, branch)
    }
    
    public func addRemote(_ name: String, _ path: String) -> (Int32, Data, Data)?
    {
        return command.run("git", "remote", "add", name, path)
    }
}
