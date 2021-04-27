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
    
    static var defaultPath: [String] = [
        "/usr/local/bin",
        "/usr/bin",
        "/bin",
        "/usr/sbin",
        "/sbin"
    ]
    
    static public func addDefaultPath(_ item: String)
    {
        defaultPath.append(item)
    }
    
    static public var swiftPath: String?
    
    public init()
    {
        self.path = Command.defaultPath
        
        if let swiftPath = Command.swiftPath
        {
            self.path.append(swiftPath)
        }
    }
    
    public func cd(_ path: String) -> Bool
    {
        guard FileManager.default.fileExists(atPath: path) else {return false}
        
        return FileManager.default.changeCurrentDirectoryPath(path)
    }
    
    public func run(_ command: String, _ args: String...) -> (exitCode: Int32, resultData: Data, errorData: Data)?
    {
        guard command.count > 0
        else
        {
            print("Run command failed. We couldn't understand the command \(command)")
            return nil
        }

        var absolutePath = command

        var pathFound = false
        if command.first! != "/"
        {
            for attempt in path
            {
                absolutePath = attempt + "/" + command
                if FileManager.default.fileExists(atPath: absolutePath)
                {
                    pathFound = true
                    break
                }
            }
        }
        else
        {
            pathFound = true
        }

        guard pathFound
        else
        {
            print("\nRun command failed. Path not found.")
            print("Path: \(path)")
            print("Command: \(command)")
            return nil
        }
        
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        let process = Process.init()
        process.executableURL = URL(fileURLWithPath: absolutePath)
        process.arguments = args
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        process.currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

        let queue = DispatchQueue(label: "childProcessOutput", attributes: .concurrent)

        let stdoutLock = DispatchGroup()
        let stdoutHandle = stdoutPipe.fileHandleForReading
        var stdoutData: Data? = nil
        stdoutLock.enter()
        queue.async
        {
            stdoutData = stdoutHandle.readDataToEndOfFile()
            stdoutLock.leave()
        }

        let stderrLock = DispatchGroup()
        let stderrHandle = stderrPipe.fileHandleForReading
        var stderrData: Data? = nil
        stderrLock.enter()
        queue.async
        {
            stderrData = stderrHandle.readDataToEndOfFile()
            stderrLock.leave()
        }

        do
        {
            try process.run()
        }
        catch
        {
            return nil
        }

        process.waitUntilExit()
        let exitCode = process.terminationStatus

        stdoutLock.wait()
        stderrLock.wait()

        guard let resultData = stdoutData else {return nil}
        guard let errData = stderrData else {return nil}

        return (exitCode, resultData, errData)
    }
}
