//
//  Files.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/2/20.
//

import Foundation

public class File
{
    static public func cd(_ path: String) -> Bool
    {
        let command = Command()
        return command.cd(path)
    }
    
    static public func get(_ path: String) -> Data?
    {
        return FileManager.default.contents(atPath: path)
    }
    
    static public func homeDirectory() -> URL
    {
        return FileManager.default.homeDirectoryForCurrentUser
    }
    
    static public func currentDirectory() -> String
    {
        return FileManager.default.currentDirectoryPath
    }
    
    static public func makeDirectory(atPath path: String) -> Bool
    {
        do
        {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
            return true
        }
        catch let dirError
        {
            print("Failed to create a directory at \(path). Error: \(dirError)")
            return false
        }
    }
    
    static public func copy(sourcePath: String, destinationPath: String) -> Bool
    {
        do
        {
            try FileManager.default.copyItem(atPath: sourcePath, toPath: destinationPath)
        }
        catch let copyError
        {
            print("Failed to copy from \(sourcePath) to \(destinationPath)\nError: \(copyError)")
            return false
        }
        
        return true
    }
    
    static public func contentsOfDirectory(atPath directoryPath: String) -> [String]?
    {
        do
        {
            let contents = try FileManager.default.contentsOfDirectory(atPath: directoryPath)
            return contents
        }
        catch
        {
            print("Failed to list contents of directory: \(error)")
            return nil
        }
    }
    
    static public func delete(atPath path: String) -> Bool
    {
        do
        {
            try FileManager.default.removeItem(atPath: path)
            return true
        }
        catch let deleteError
        {
            print("Failed to remove error at \(deleteError)")
            return false
        }
    }
    
    static public func move(sourcePath: String, destinationPath: String) -> Bool
    {
        do
        {
            try FileManager.default.moveItem(atPath: sourcePath, toPath: destinationPath)
        }
        catch let moveError
        {
            print("Failed to copy from \(sourcePath) to \(destinationPath)\nError: \(moveError)")
            return false
        }
        
        return true
    }
    
    static public func put(_ path: String, contents: Data) -> Bool
    {
        let url = URL(fileURLWithPath: path)
        
        do
        {
            try contents.write(to: url)
        }
        catch
        {
            return false
        }
        
        return true
    }

    static public func exists(_ path: String) -> Bool
    {
        return FileManager.default.fileExists(atPath: path)
    }

    static public func untargzip(path: String, outputPath: String? = nil) -> Bool
    {
        let command = Command()

        if let outputDir = outputPath
        {
            guard let _ = command.run("tar", "xvzf", path, "-C", outputDir) else {return false}
        }
        else
        {
            guard let _ = command.run("tar", "xvzf", path) else {return false}
        }

        return true
    }
    
    static public func zip(sourcePath: String, outputPath: String) -> Bool
    {
        #if os(Linux)
        guard let _ = Apt.install("zip")
        else
        {
            print("Failed to install zip.")
            return false
        }
        #endif
        
        let command = Command()
        guard let _ = command.run("zip", "-r", outputPath, sourcePath)
        else
        {
            print("Failed to zip \(sourcePath) to \(outputPath)")
            return false
        }
        
        return true
    }
    
    static public func with(directory: String, completion: () -> Bool) -> Bool
    {
        let startingDirectory = File.currentDirectory()
        
        guard File.cd(directory)
        else { return false }
        
        let result = completion()
        
        guard File.cd(startingDirectory)
        else
        {
            print("Warning: we failed to return to the starting directory after executing commands.")
            print("Starting directory: \(startingDirectory)")
            print("Current directory: \(File.currentDirectory())")
            return result
            
        }
        
        return result
    }
}
