//
//  Swift.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/2/20.
//

import Foundation
import Datable

public class Go
{
    var command = Command()

    static public func install() -> Bool
    {
        #if os(Linux)
        guard let _ = Apt.install("golang")
        else
        {
            print("Failed to install Go")
            return false
        }
        return true
        #else
        print("Installing go is currently only supported on Linux os.")
        return false
        #endif
    }
    
    public func cd(_ path: String) -> Bool
    {
        return command.cd(path)
    }
    
    public func get(updatePackages: Bool) -> (Int32, Data, Data)?
    {
        if updatePackages
        {
            return command.run("go", "get", "-u")
        }
        else
        {
            return command.run("go", "get")
        }
    }
    
    public func build() -> (Int32, Data, Data)?
    {
        return command.run("go", "build")
    }
    
    public func test() -> (Int32, Data, Data)?
    {
        return command.run("go", "test")
    }

    // FIXME - needs program name argument
    public func run() -> (Int32, Data, Data)?
    {
        return command.run("go", "run")
    }
    
    /// Clones repository, checks out the correct branch, and builds
    /// Returns: The path to the built target
    public func buildFromRepository(repositoryPath: String, branch: String, target: String) -> String?
    {
        let git = Git()
        
        guard let repositoryURL = URL(string: repositoryPath)
        else
        {
            print("Invalid repository path \(repositoryPath)")
            return nil
        }
        
        let repositoryName = repositoryURL.deletingPathExtension().lastPathComponent
        
        guard let _ = git.clone(repositoryPath)
        else
        {
            print("Unable to clone \(repositoryPath)")
            return nil
        }
        
        guard git.cd(repositoryName)
        else
        {
            print("Unable to change directory to \(repositoryName).")
            return nil
        }
        
        guard let _ = git.checkout(branch)
        else
        {
            print("Unable to checkout \(branch) branch.")
            return nil
        }
        
        guard let _ = get(updatePackages: true)
        else
        {
            print("Failed the 'go get' command.")
            return nil
        }
        
        let targetPath = File.homeDirectory().appendingPathComponent("go").appendingPathComponent("bin").appendingPathComponent(target).path
        
        guard File.exists(targetPath)
        else
        {
            print("Target \(target) does not exist at \(targetPath)")
            return nil
        }
        
        return targetPath
    }
}
