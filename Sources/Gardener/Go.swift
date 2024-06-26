//
//  Swift.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/2/20.
//
#if os(iOS) || os(watchOS) || os(tvOS)
#else
import Foundation
import Datable

public class Go
{
    static let latestGo = "1.15.6"
    static let goVersionString = "go\(latestGo)"
    static let goFilename = "go\(latestGo).linux-amd64.tar.gz"
    static let goUrl = URL(string: "https://golang.org/dl/\(goFilename)")!
    static let bin = "/usr/local/go/bin/go"

    var command = Command()

    public init()
    {
        // Public Initializer
    }

    static public func install() -> Bool
    {
        #if os(Linux)
        let go = Go()
        if isInstalled, isLatestVersion
        {
            return true
        }

        guard let _ = Apt.install("wget")
        else
        {
            print("Failed to install wget.")
            return false
        }

        if File.exists(goFilename)
        {
            guard File.delete(atPath: goFilename)
            else
            {
                print("Failed to delete old go file \(goFilename).")
                return false
            }
        }

        let urlString = goUrl.absoluteString
        guard let _ = go.command.run("wget", "-O", goFilename, urlString)
        else
        {
            print("Failed to wget \(urlString)")
            return false
        }

        guard File.untargzip(path: Go.goFilename, outputPath: "/usr/local")
        else
        {
            print("Failed to untar the Go file.")
            return false
        }

        guard Go.isInstalled
        else
        {
            print("Failed to install Go.")
            return false
        }
        
        guard Go.isLatestVersion
        else
        {
            print("Failed to install the latest version of Go.")
            print("Reported version = \(go.version() ?? "nil")")
            print("Required version = \(goVersionString)")
            return false
        }

        return true
        
        #else
        
        print("Installing go is currently only supported on Linux os.")
        return false
        
        #endif
    }

    public static var isInstalled: Bool
    {
        return File.exists(Go.bin)
    }

    public static var isLatestVersion: Bool
    {
        let go = Go()
        return go.version() == goVersionString
    }

    public func cd(_ path: String) -> Bool
    {
        return command.cd(path)
    }
    
    public func get(updatePackages: Bool) -> (Int32, Data, Data)?
    {
        if updatePackages
        {
            return command.run(Go.bin, "get", "-u")
        }
        else
        {
            return command.run(Go.bin, "get")
        }
    }

    public func version() -> String?
    {
        print("Checking go version...")
        print("\(Go.bin) version")
        
        guard let (_, output, _) = command.run("\(Go.bin)", "version")
        else
        {
            print("Failed to identify what version of go is installed at \(Go.bin)")
            return nil
        }
        
        guard let table = tabulate(string: output.string)
        else
        {
            print("Failed to tabulate output: \(output.string)")
            return nil
        }
        
        guard let label = table.columns[0].label
        else
        {
            return nil
        }
        
        let strings = label.components(separatedBy: " ")
        return strings[2]
    }

    public func build() -> (Int32, Data, Data)?
    {
        return command.run(Go.bin, "build")
    }
    
    public func test() -> (Int32, Data, Data)?
    {
        return command.run(Go.bin, "test")
    }

    // FIXME - needs program name argument
    public func run() -> (Int32, Data, Data)?
    {
        return command.run(Go.bin, "run")
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
        
        let result = File.with(directory: repositoryName)
        {
            () -> Bool in
            
            do
            {
                try git.checkout(branch)
            }
            catch
            {
                print("Unable to checkout \(branch) branch.")
                return false
            }
            
            guard let _ = get(updatePackages: true)
            else
            {
                print("Failed the 'go get' command.")
                return false
            }

            return true
        }
        
        guard result
        else { return nil }
        
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
#endif
