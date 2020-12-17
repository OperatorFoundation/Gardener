//
//  SSH.swift
//  
//
//  Created by Dr. Brandon Wiley on 12/9/20.
//

import Foundation

public class SSH
{
    let remoteHost: String

    // Fails if remote host is unreachable
    public init?(username: String, host: String, port: Int? = nil)
    {
        if let realPort = port, realPort != 22
        {
            remoteHost = "\(username)@\(host):\(realPort)"
        }
        else
        {
            remoteHost = "\(username)@\(host)"
        }
        guard ping() else {return nil}
    }

    public func remote(command: String) -> (Int32, Data, Data)?
    {
        let runner = Command()

        print("SSH(\(remoteHost)): running remote command \"\(command)\"")
        let maybeResult = runner.run("ssh", remoteHost, command)
        if let (exitCode, data, errorData) = maybeResult
        {
            print("Exit code: \(exitCode)")

            if data.count == 0 && errorData.count == 0
            {
                print("No output.")
            }
            else
            {
                if data.count > 0
                {
                    print("Output:")
                    if data.string.last == "\n"
                    {
                        print(data.string, terminator: "")
                    }
                    else
                    {
                        print(data.string)
                    }
                }

                if errorData.count > 0
                {
                    print("Error:")
                    if errorData.string.last == "\n"
                    {
                        print(errorData.string, terminator: "")
                    }
                    else
                    {
                        print(errorData.string)
                    }
                }
            }
            print("-------------------")
        }
        else
        {
            print("Command failed.")
            print("-------------------")
        }

        return maybeResult
    }

    public func ping() -> Bool
    {
        guard let (_, output, errData) = remote(command: "echo pong") else {return false}
        return output.string == "pong\n"
    }

    public func fileExists(path: String) -> Bool
    {
        guard let (result, data, errData) = remote(command: "ls -d \"\(path)\"") else {return false}
        guard result == 0 else {return false}
        guard let table = tabulate(string: data.string, headers: false, oneSpaceAllowed: false) else {return false}

        // Found file in ls output
        if table.columns[0].findRowIndex(value: path) != nil
        {
            return true
        }
        else
        {
            return false
        }
    }

    public func download(url: URL, outputFilename: String, sha1sum: String) -> Bool
    {
        // File exists
        if let digest = self.sha1sum(path: outputFilename)
        {
            // Digests match
            if digest == sha1sum
            {
                // We're done!
                return true
            }
            else // Digests don't match
            {
                // Delete old, bad file
                rm(path: outputFilename)

                // Continue on to download
            }
        }

        // File does not exist, or had a bad digest and we deleted it.
        install(package: "wget")

        let urlString = url.absoluteString
        guard let (result, _, errData) = remote(command: "wget -O \(outputFilename) \"\(urlString)\"") else {return false}
        return true
    }

    public func sha1sum(path: String) -> String?
    {
        guard let (result, data, errData) = remote(command: "sha1sum \"\(path)\"") else {return nil}
        guard let table = tabulate(string: data.string, headers: false, oneSpaceAllowed: false) else {return nil}
        return table.columns[0].fields[0]
    }

    public func rm(path: String, force: Bool = false) -> Bool
    {
        if force
        {
            guard let (result, data, errData) = remote(command: "rm -rf \"\(path)\"") else {return false}
        }
        else
        {
            guard let (result, data, errData) = remote(command: "rm \"\(path)\"") else {return false}
        }
        return true
    }

    public func unzip(path: String) -> String?
    {
        guard let (result, _, errData) = remote(command: "unzip \"\(path)\"") else {return nil}
        return nil
    }

    public func untargzip(path: String) -> String?
    {
        guard let (result, _, errData) = remote(command: "tar zxf \"\(path)\"") else {return nil}
        return nil
    }

    // Idempotent file append
    public func append(path: String, string: String) -> Bool
    {
        guard let (result, data, errData) = remote(command: "grep \"\(string)\" \"\(path)\"") else {return false}

        // String is already in file
        if data.string == string
        {
            // We're done!
            return true
        }

        // Append string to file
        guard let _ = remote(command: "echo '\(string)' >>\"\(path)\"") else {return false}
        return false
    }

    public func install(package: String) -> Bool
    {
        guard let (result, _, errData) = remote(command: "apt install \(package)") else {return false}
        return true
    }

    public func swiftVersion(path: String) -> String?
    {
        guard let (result, data, errData) = remote(command: "\(path)/swift -version") else {return nil}
        guard result == 0 else {return nil}
        guard let table = tabulate(string: data.string, headers: false, oneSpaceAllowed: false) else {return nil}
        return table.columns[0].fields[0]
    }

    public func swiftRun(path: String, target: String) -> Int32?
    {
        guard let (result, _, _) = remote(command: "cd \(path); swift run \(target)") else {return nil}
        return result
    }

    public func gitClone(source: URL, branch: String) -> Bool
    {
        let clonePath = source.absoluteString
        var packageName = source.deletingPathExtension().lastPathComponent

        if fileExists(path: packageName)
        {
            guard let (result, data, errData) = remote(command: "cd \(packageName); git checkout \(branch); git pull origin \(branch)") else {return false}
            return true
        }
        else
        {
            guard let (result, data, errData) = remote(command: "git clone \(source)") else {return false}
            return true
        }
    }
}