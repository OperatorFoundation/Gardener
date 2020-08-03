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

    public func cd(_ path: String) -> Bool
    {
        return command.cd(path)
    }
    
    public func initialize() -> (Int32, Data)?
    {
        return command.run("git", "init")
    }
    
    public func checkout(_ path: String) -> (Int32, Data)?
    {
        return command.run("git", "checkout", path)
    }
    
    public func pull(_ remote: String, _ branch: String) -> (Int32, Data)?
    {
        return command.run("git", "pull", remote, branch)
    }
    
    public func push(_ remote: String, _ branch: String) -> (Int32, Data)?
    {
        return command.run("git", "push", remote, branch)
    }
    
    public func addRemote(_ name: String, _ path: String) -> (Int32, Data)?
    {
        return command.run("git", "remote", "add", name, path)
    }
}
