//
//  Git.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/2/20.
//
#if os(iOS) || os(watchOS) || os(tvOS)
#else
import Foundation

// https://git-scm.com/docs/git-status

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

    public func status() throws -> [GitFileStatusItem]
    {
        guard let (_, output, _) = command.run("git", "status") else
        {
            return []
        }

        guard output.count > 0 else
        {
            return []
        }

        let lines = output.string.split(separator: "\n").map { String($0) }
        return try lines.map
        {
            line in

            return try GitFileStatusItem(line)
        }
    }
}

public class GitFileStatusItem
{
    public let x: GitFileStatus
    public let y: GitFileStatus
    public let name: String

    public convenience init(_ string: String) throws
    {
        let parts = string.split(separator: " ").map { String($0) }
        guard parts.count > 1 else
        {
            throw GitError.badFileStatus(string)
        }

        let statusString = parts[0]
        let filename = parts[1]

        guard statusString.count == 2 else
        {
            throw GitError.badStatus(statusString)
        }

        let xString = String(statusString[statusString.startIndex..<statusString.index(before: statusString.endIndex)])
        let yString = String(statusString[statusString.index(after: statusString.startIndex)..<statusString.index(before: statusString.endIndex)])

        guard let x = GitFileStatus(rawValue: xString) else
        {
            throw GitError.badStatus(xString)
        }

        guard let y = GitFileStatus(rawValue: yString) else
        {
            throw GitError.badStatus(yString)
        }

        try self.init(x: x, y: y, name: filename)
    }

    public init(x: GitFileStatus, y: GitFileStatus, name: String) throws
    {
        self.x = x
        self.y = y
        self.name = name
    }
}

public enum GitFileStatus: String
{
    case unmodified = ""
    case modified = "M"
    case fileTypeChanged = "T"
    case added = "A"
    case deleted = "D"
    case renamed = "R"
    case copied = "C"
    case updated = "U"
    case untracked = "?"
    case ignored = "!"
}

public enum GitError: Error
{
    case invalidStatusCombination(GitFileStatus, GitFileStatus)
    case badFileStatus(String)
    case badStatus(String)
}
#endif
