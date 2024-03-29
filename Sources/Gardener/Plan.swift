//
//  Plan.swift
//  
//
//  Created by Dr. Brandon Wiley on 9/15/20.
//

import Foundation

public class Plan
{
    let servers: [Server] = []
}

public class Server
{
    let ip: String?
    let image: String
    let configuration: String
    let region: String
    let name: String
    let sshKeys: [String]

    public init(ip: String? = nil, image: String, configuration: String, region: String, name: String, sshKeys: [String] = [])
    {
        self.ip = ip
        self.image = image
        self.configuration = configuration
        self.region = region
        self.name = name
        self.sshKeys = sshKeys
    }
}
