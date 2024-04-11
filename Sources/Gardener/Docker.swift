//
//  Docker.swift
//  
//
//  Created by Dr. Brandon Wiley on 4/10/24.
//

#if os(iOS) || os(watchOS) || os(tvOS)
#else
import Foundation

public class Docker
{
    var command: Command

    public init?()
    {
        command = Command()
    }

    public func cd(_ path: String) -> Bool
    {
        return command.cd(path)
    }

    public func pull(_ image: String) throws
    {
        guard let (errorCode, stdout, stderr) = command.run("docker", "pull", "image") else
        {
            throw DockerError.commandNotFound
        }

        guard errorCode == 0 else
        {
            throw DockerError.commandFailed(errorCode, stdout.string, stderr.string)
        }
    }

    public func build(_ path: String, name: String? = nil, tag: String? = nil) throws
    {
        var commandArguments = ["build"]

        if let name
        {
            commandArguments.append("-t")

            if let tag
            {
                commandArguments.append("\(name):\(tag)")
            }
            else
            {
                commandArguments.append(name)
            }
        }

        commandArguments.append(path)

        guard let (errorCode, stdout, stderr) = command.run("docker", commandArguments) else
        {
            throw DockerError.commandNotFound
        }

        guard errorCode == 0 else
        {
            throw DockerError.commandFailed(errorCode, stdout.string, stderr.string)
        }
    }

    public func run(_ image: String, tty: Bool = false, interactive: Bool = false, portMappings: [Int: Int] = [:]) throws
    {
        var commandArguments = ["run"]

        if tty
        {
            commandArguments.append("-t")
        }

        if interactive
        {
            commandArguments.append("-i")
        }

        if portMappings.count > 0
        {
            commandArguments.append("-p")

            for (key, value) in portMappings
            {
                commandArguments.append("\(key):\(value)")
            }
        }

        commandArguments.append(image)

        guard let (errorCode, stdout, stderr) = command.run("docker", commandArguments) else
        {
            throw DockerError.commandNotFound
        }

        guard errorCode == 0 else
        {
            throw DockerError.commandFailed(errorCode, stdout.string, stderr.string)
        }
    }
}

public enum DockerError: Error
{
    case commandNotFound
    case commandFailed(Int32, String, String)
}
#endif
