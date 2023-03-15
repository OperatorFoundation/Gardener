//
//  Files.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/2/20.
//

import Foundation
import SystemPackage

import Glob

public class File
{
    static var pushedDirectories: [String] = []
    
    #if os(iOS) || os(watchOS) || os(tvOS)
    static public func homeDirectory() -> URL
    {
        let documentDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return documentDirectories[0]
    }
    #else
    static public func cd(_ path: String) -> Bool
    {
        let command = Command()
        return command.cd(path)
    }
    
    static public func pushd(_ directory: String) -> Bool
    {
        let current = self.currentDirectory()
        self.pushedDirectories.append(current)
        guard cd(directory) else {
            return false
        }
        return true
    }
    
    static public func popd() -> Bool
    {
        guard let originalDirectory = self.pushedDirectories.popLast() else
        {
            return false
        }
        guard cd(originalDirectory) else
        {
            return false
        }
        return true
    }

    static public func homeDirectory() -> URL
    {
        return FileManager.default.homeDirectoryForCurrentUser
    }

    static public func targzip(name: String, directoryPath: String) -> Bool
    {
        let command = Command()
        
        guard exists(directoryPath)
        else
        {
            print("Nothing found at \(directoryPath)")
            return false
        }
        
        guard let _ = command.run("tar", "cvzf", name, directoryPath)
        else
        {
            print("Failed to tar directory at \(directoryPath)")
            return false
        }

        return true
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
    #endif

    static public func currentDirectory() -> String
    {
        return FileManager.default.currentDirectoryPath
    }

    static public func applicationSupportDirectory() -> URL
    {
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
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

    static public func makeDirectory(url: URL) -> Bool
    {
        do
        {
            try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true)
            return true
        }
        catch let dirError
        {
            print("Failed to create a directory at \(url.path). Error: \(dirError)")
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

    // Surprisingly hard to do in Swift. The usual way of doing this depends on Obj-C and so its not cross-platform, so we use the multi-platform System library instead.
    static public func isDirectory(_ path: String) -> Bool
    {
        guard File.exists(path) else {return false}

        let filepath: FilePath = FilePath(path)
        do
        {
            let fd = try FileDescriptor.open(filepath, .readOnly, options: [.directory])
            try fd.close()

            return true
        }
        catch
        {
            return false
        }
    }

    // Like the Unix touch command, creates a file of zero length.
    static public func touch(_ path: String) -> Bool
    {
        guard !File.exists(path) else {return true}

        let filepath: FilePath = FilePath(path)
        do
        {
            let fd = try FileDescriptor.open(filepath, .writeOnly, options: [.create], permissions: .ownerReadWrite)
            try fd.close()

            return true
        }
        catch
        {
            return false
        }
    }

    static public func tempFile(ext: String? = nil) throws -> URL
    {
        let temporaryDirectoryURL = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

        var temporaryFilename = ProcessInfo.processInfo.globallyUniqueString
        if let suffix = ext
        {
            temporaryFilename.append(suffix)
        }

        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
        return temporaryFileURL
    }

    static public func cacheableFile(directory: String? = nil, name: String) throws -> URL
    {
        var temporaryDirectoryURL = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

        if let dir = directory
        {
            temporaryDirectoryURL = temporaryDirectoryURL.appendingPathComponent(dir)
            if !File.exists(temporaryDirectoryURL.path)
            {
                guard File.makeDirectory(url: temporaryDirectoryURL) else
                {
                    throw FileError.couldNotCreateDirectory
                }
            }
        }

        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(name)
        return temporaryFileURL
    }

    static public func findFiles(_ path: URL) -> [URL]
    {
        guard let enumeration = FileManager.default.enumerator(atPath: path.path) else
        {
            return []
        }

        for file in enumeration
        {
            print(file)
        }

        return []
    }

    static public func findFiles(_ path: URL, pattern: String) -> [URL]
    {
        return Glob(pattern: "\(path.path)/\(pattern)").map
        {
            path in

            URL(fileURLWithPath: path)
        }
    }
    
    static public func findDirectories(_ path: URL) throws -> [URL]
    {
        return try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: [URLResourceKey.isDirectoryKey])
    }

    static public func get(_ path: String) -> Data?
    {
        return FileManager.default.contents(atPath: path)
    }

    static public func size(_ url: URL) throws -> Int
    {
        guard let fileAttributes = try? FileManager.default.attributesOfItem(atPath: url.path) else
        {
            throw FileError.fileNotFound(url)
        }

        guard let size = fileAttributes[.size] as? Int64 else
        {
            throw FileError.fileNotFound(url)
        }

        return Int(size)
    }
}

public enum FileError: Error
{
    case couldNotCreateDirectory
    case fileNotFound(URL)
}
