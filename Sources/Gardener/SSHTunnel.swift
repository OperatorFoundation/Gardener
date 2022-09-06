//
//  SSHTunnel.swift
//  
//
//  Created by Dr. Brandon Wiley on 9/6/22.
//

import Foundation

public class SSHTunnel
{
    let remoteHost: String
    let task: Cancellable

    public init?(username: String, host: String, port: Int? = nil, tunnelRemoteListenPort: Int, tunnelLocalListenPort: Int)
    {
        if let realPort = port, realPort != 22
        {
            self.remoteHost = "\(username)@\(host):\(realPort)"
        }
        else
        {
            self.remoteHost = "\(username)@\(host)"
        }

        let runner = Command()

        print("SSH(\(remoteHost)): server listening on \(tunnelLocalListenPort) and forwarding to local port \(tunnelLocalListenPort)")

        guard let task = runner.runWithCancellation("ssh", "-R", "\(tunnelRemoteListenPort):localhost:\(tunnelLocalListenPort)", self.remoteHost) else
        {
            return nil
        }
        self.task = task
    }

    public func stop()
    {
        self.task.cancel()
    }
}
