//
//  Command.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/2/20.
//

import Foundation

public class Command
{
    var path: [String]
    
    public init()
    {
        self.path = [
            "/usr/local/bin",
            "/usr/bin",
            "/bin",
            "/usr/sbin",
            "/sbin"
        ]
    }
    
    public func cd(_ path: String) -> Bool
    {
        guard FileManager.default.fileExists(atPath: path) else {return false}
        
        return FileManager.default.changeCurrentDirectoryPath(path)
    }
    
    public func run(_ command: String, _ args: String...) -> (Int32, Data)?
    {
        guard command.count > 0 else {return nil}

        var absolutePath = command
        
        if command.first! != "/"
        {
            for attempt in path
            {
                absolutePath = attempt + "/" + command
                if FileManager.default.fileExists(atPath: absolutePath)
                {
                    break
                }
            }
            
            return nil
        }
        
        let pipe = Pipe()
        let process = Process.launchedProcess(launchPath: absolutePath, arguments: args)
        process.standardOutput = pipe
        process.waitUntilExit()
        let exitCode = process.terminationStatus
        
        let handle = pipe.fileHandleForReading
        let data = handle.readDataToEndOfFile()
        
        return (exitCode, data)
    }
}
