//
//  EdgeDB.swift
//
//
//  Created by Dr. Brandon Wiley on 7/12/24.
//
#if os(iOS) || os(watchOS) || os(tvOS)
#else
import Foundation

import Datable

public class EdgeDB
{
    public let migration: EdgeDBMigration
    public let database: EdgeDBDatabase
    public let describe: EdgeDBDescribe
    public let project: EdgeDBProject
    public let instance: EdgeDBInstance

    let databaseDirectory: String

    var command = Command()

    public init(databaseDirectory: String, options: EdgeDBOptions? = nil) throws
    {
        // Public initializer
        self.databaseDirectory = databaseDirectory

        let result = self.command.cd(databaseDirectory)
        guard result else
        {
            throw EdgeDBError.unknownDatabaseDirectory
        }

        self.migration = EdgeDBMigration(self.command)
        self.database = EdgeDBDatabase(self.command)
        self.describe = EdgeDBDescribe(self.command)
        self.project = EdgeDBProject(self.command)
        self.instance = EdgeDBInstance(self.command)
    }

    public func dump() -> (Int32, Data, Data)?
    {
        return self.command.run("edgedb", "dump")
    }

    public func restore() -> (Int32, Data, Data)?
    {
        return self.command.run("edgedb", "restore")
    }

    public func loadSchema(module: String = "default") throws -> String
    {
        let directoryURL = URL(fileURLWithPath: databaseDirectory)
        let fileURL = directoryURL.appendingPathComponent("dbschema", isDirectory: true).appendingPathComponent("\(module).esdl")
        let data = try Data(contentsOf: fileURL)
        return data.string
    }

    public func saveSchema(module: String = "default", newSchema: String) throws
    {
        let data = newSchema.data

        let directoryURL = URL(fileURLWithPath: databaseDirectory)
        let fileURL = directoryURL.appendingPathComponent("dbschema", isDirectory: true).appendingPathComponent("\(module).esdl")

        try data.write(to: fileURL)
    }
}

public class EdgeDBMigration
{
    let command: Command

    public init(_ command: Command)
    {
        self.command = command
    }

    public func create() throws
    {
        guard let (errorCode, _, _) = self.command.run("edgedb", "migration", "create", "--no-interactive") else
        {
            throw EdgeDBError.commandFailed
        }

        switch errorCode
        {
            case 0:
                return

            case 1:
                throw EdgeDBError.generalError

            case 4:
                throw EdgeDBMigrationError.noChangesDetected

            default:
                throw EdgeDBError.unknownErrorCode(errorCode)
        }
    }

    public func apply() throws
    {
        guard let (errorCode, _, _) = self.command.run("edgedb", "migration", "apply") else
        {
            throw EdgeDBError.commandFailed
        }

        switch errorCode
        {
            case 0:
                return

            default:
                throw EdgeDBError.unknownErrorCode(errorCode)
        }
    }

    public func status() -> (Int32, Data, Data)?
    {
        return self.command.run("edgedb", "migration", "status")
    }

    public func log() -> (Int32, Data, Data)?
    {
        return self.command.run("edgedb", "migration", "log")
    }
}

public class EdgeDBDatabase
{
    let command: Command

    public init(_ command: Command)
    {
        self.command = command
    }
}

public class EdgeDBDescribe
{
    let command: Command

    public init(_ command: Command)
    {
        self.command = command
    }
}

public class EdgeDBProject
{
    let command: Command

    public init(_ command: Command)
    {
        self.command = command
    }
}

public class EdgeDBInstance
{
    let command: Command

    public init(_ command: Command)
    {
        self.command = command
    }
}

public struct EdgeDBOptions
{
}

public enum EdgeDBError: Error
{
    case unknownDatabaseDirectory
    case commandFailed
    case unknownErrorCode(Int32)
    case generalError
}

public enum EdgeDBMigrationError: Error
{
    case noChangesDetected
}
#endif
