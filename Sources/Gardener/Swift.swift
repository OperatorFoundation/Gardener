//
//  Swift.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/2/20.
//

import Foundation
import Datable

public class Swift
{
    var command = Command()
    
    //FIXME: Solution for Linux
    #if os(macOS)
    static public func install(os: String) -> Bool
    {
        let baseURL = URL(string: "https://swift.org")!
        let releasesPageURL: URL = baseURL.appendingPathComponent("/download/#releases")
        guard let releasesPage = try? String(contentsOf: releasesPageURL) else {return false}

        guard let line = releasesPage.findLine(pattern: "ubuntu\(os).tar.gz") else {return false}
        guard let untrimmedDownloadPath = line.extract(pattern: #"<a href=\"([^\"]+)\">"#) else {return false}
        let downloadPath = untrimmedDownloadPath.trimmingCharacters(in: CharacterSet(arrayLiteral: "\""))
            
        let downloadURL = baseURL.appendingPathComponent(downloadPath)
        let filename = downloadURL.lastPathComponent
        let outputURL = URL(fileURLWithPath: filename)

        // FIXME: Downloader is currently only written for macOS
        guard Downloader.download(from: downloadURL, to: outputURL) else {return false}
        
        let command = Command()
        guard let (exitCode, data, _) = command.run("tar", "zxvf", filename) else {return false}
        guard exitCode == 0 else {return false}

        let tarline = String(data.string.split(separator: "\n")[0])
        let dirname = String(tarline.split(separator: " ")[8])
        Gardener.instance.swiftPath = dirname
        
        return true
    }
    #endif
    
    public func cd(_ path: String) -> Bool
    {
        return command.cd(path)
    }
    
    public func initialize() -> (Int32, Data, Data)?
    {
        return command.run("swift", "package", "init")
    }
    
    public func update() -> (Int32, Data, Data)?
    {
        return command.run("swift", "package", "update")
    }
    
    public func generate() -> (Int32, Data, Data)?
    {
        return command.run("swift", "package", "generate-xcodeproj")
    }
    
    public func build() -> (Int32, Data, Data)?
    {
        return command.run("swift", "build")
    }
    
    public func test() -> (Int32, Data, Data)?
    {
        return command.run("swift", "test")
    }
    
    public func run() -> (Int32, Data, Data)?
    {
        return command.run("swift", "run")
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
        
        guard File.cd(repositoryName)
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
        
        guard let _ = build()
        else
        {
            print("Failed to build \(repositoryName)")
            return nil
        }
        
        let targetPath = ".build/x86_64-unknown-linux-gnu/debug/\(target)"
        guard File.exists(targetPath)
        else
        {
            print("Target \(target) does not exist at \(targetPath)")
            return nil
        }
        
        return targetPath
    }
}
