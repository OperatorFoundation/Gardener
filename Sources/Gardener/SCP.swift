//
//  SCP.swift
//  
//
//  Created by Dr. Brandon Wiley on 1/4/21.
//

import Foundation

public class SCP
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

        guard let ssh = SSH(username: username, host: host, port: port) else {return nil}
        guard ssh.ping() else {return nil}
    }

    public func download(remotePath: String, localPath: String) -> (Int32, Data, Data)?
    {
        let runner = Command()

        print("SCP(\(remoteHost)): \(remotePath) -> \(localPath)")
        
        let maybeResult = runner.run("scp", "\(remoteHost):\(remotePath)", "\(localPath)")
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
            print("Download failed.")
            print("-------------------")
        }

        return maybeResult
    }

    public func upload(remotePath: String, localPath: String) -> (Int32, Data, Data)?
    {
        let runner = Command()

        print("SCP(\(remoteHost)): \(remotePath) <- \(localPath)")
        let maybeResult = runner.run("scp", "\(localPath) \(remoteHost):\(remotePath)")
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
            print("Download failed.")
            print("-------------------")
        }

        return maybeResult
    }
}
