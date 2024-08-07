//
//  Command.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/2/20.
//
#if os(iOS) || os(watchOS) || os(tvOS)
#else
import Foundation

public class Command
{
    var path: [String]
    
    static var defaultPath: [String] = [
        "/usr/local/bin",
        "/usr/bin",
        "/bin",
        "/usr/sbin",
        "/sbin",
        "/opt/homebrew/bin"
    ]
    
    static public func addDefaultPath(_ item: String)
    {
        if !defaultPath.contains(item)
        {
            defaultPath.append(item)
        }
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

    public func addPath(_ item: String)
    {
        if !self.path.contains(item)
        {
            self.path.append(item)
        }
    }

    public func addPathFirst(_ item: String)
    {
        if !self.path.contains(item)
        {
            self.path = [item] + self.path
        }
    }
    
    public func cd(_ path: String) -> Bool
    {
        guard FileManager.default.fileExists(atPath: path) else {return false}
        
        return FileManager.default.changeCurrentDirectoryPath(path)
    }

    public func runQuiet(_ command: String, _ args: String...) -> Bool
    {
        return self.runQuiet(command, args)
    }

    public func runQuiet(_ command: String, _ args: [String]) -> Bool
    {
        guard command.count > 0
        else
        {
            print("Run command failed. We couldn't understand the command \(command)")
            return false
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
            return false
        }

        let process = Process.init()
        process.executableURL = URL(fileURLWithPath: absolutePath)
        process.arguments = args
        process.currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

        do
        {
            try process.run()
        }
        catch
        {
            return false
        }

        process.waitUntilExit()

        return true
    }
    
    public func run(_ command: String, _ args: String...) -> (exitCode: Int32, resultData: Data, errorData: Data)?
    {
        return self.run(command, args)
    }

    public func run(_ command: String, _ args: [String]) -> (exitCode: Int32, resultData: Data, errorData: Data)?
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
    
    public func runWithCancellation(_ command: String, _ args: String...) -> Cancellable?
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

        do
        {
            try process.run()
        }
        catch
        {
            return nil
        }

        return Cancellable(process: process, stdoutHandle: stdoutPipe.fileHandleForReading, stderrHandle: stderrPipe.fileHandleForReading)
    }

    public func runWithPipes(_ command: String, _ args: String...) -> CancellablePipes?
    {
        return self.runWithPipes(command, args)
    }

    public func runWithPipes(_ command: String, _ args: [String]) -> CancellablePipes?
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

        let stdinPipe = Pipe()
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        let process = Process.init()
        process.executableURL = URL(fileURLWithPath: absolutePath)
        process.arguments = args
        process.standardInput = stdinPipe
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        process.currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

        do
        {
            try process.run()
        }
        catch
        {
            return nil
        }

        return CancellablePipes(process: process, stdinHandle: stdinPipe.fileHandleForWriting , stdoutHandle: stdoutPipe.fileHandleForReading, stderrHandle: stderrPipe.fileHandleForReading)
    }

}

public class Cancellable
{
    let process: Process
    let queue = DispatchQueue(label: "CancellableQueue", attributes: .concurrent)
    
    var stdoutLock = DispatchGroup()
    var stdoutHandle: FileHandle
    var stdoutData: Data? = nil
    
    var stderrLock = DispatchGroup()
    var stderrHandle: FileHandle
    var stderrData: Data? = nil
    
    public init(process: Process, stdoutHandle: FileHandle, stderrHandle: FileHandle)
    {
        self.process = process
        self.stdoutHandle = stdoutHandle
        self.stderrHandle = stderrHandle
        
        self.stdoutLock.enter()
        self.queue.async
        {
            self.stdoutData = self.stdoutHandle.readDataToEndOfFile()
            self.stdoutLock.leave()
        }
        
        self.stderrLock.enter()
        self.queue.async
        {
            self.stderrData = self.stderrHandle.readDataToEndOfFile()
            self.stderrLock.leave()
        }
    }
    
    public func wait() -> (exitCode: Int32, resultData: Data, errorData: Data)?
    {
        self.process.waitUntilExit()
        let exitCode = self.process.terminationStatus
        
        self.stdoutLock.wait()
        guard let resultData = stdoutData else
        {
            return nil
        }
        
        self.stderrLock.wait()
        guard let errorData = self.stderrData else
        {
            return nil
        }
        
        return (exitCode, resultData, errorData)
    }
    
    public func cancel() -> (exitCode: Int32, resultData: Data, errorData: Data)?
    {
        self.process.interrupt()
        if process.isRunning
        {
            process.terminate()
        }
        
        return self.wait()
    }
}

public class CancellablePipes
{
    let process: Process

    var stdinHandle: FileHandle
    var stdoutHandle: FileHandle
    var stderrHandle: FileHandle

    public init(process: Process, stdinHandle: FileHandle, stdoutHandle: FileHandle, stderrHandle: FileHandle)
    {
        self.process = process
        self.stdinHandle = stdinHandle
        self.stdoutHandle = stdoutHandle
        self.stderrHandle = stderrHandle
    }

    public func wait() -> Int32?
    {
        self.process.waitUntilExit()
        return self.process.terminationStatus
    }

    public func cancel() -> Int32?
    {
        self.process.interrupt()
        if process.isRunning
        {
            process.terminate()
        }

        return self.wait()
    }
}

#endif
