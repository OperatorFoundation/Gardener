//
//  DO.swift
//  
//
//  Created by Dr. Brandon Wiley on 9/15/20.
//

import Foundation

public class DO
{
    static public func auth() -> (Int32, String, String)?
    {
        let command = Command()
        guard let (exitCode, data, errData) = command.run("doctl", "auth", "init") else {return nil}
        return (exitCode, data.string, errData.string)
    }

    static public func create(server: Server) -> String?
    {
        guard let dropletId = DO.Droplet.create(server: server) else {return nil}
        guard let _ = DO.FloatingIP.assign(ip: server.ip, dropletId: dropletId) else
        {
            // FIXME: rollback droplet creation on failure?
            return nil
        }

        return dropletId
    }

    static public func delete(server: Server) -> Bool
    {
        guard let dropletId = DO.FloatingIP.getAssignment(ip: server.ip) else {return false}
        guard let _ = DO.Droplet.delete(dropletId: dropletId) else {return false}

        return true
    }

    public class Droplet
    {
        static public func create(server: Server) -> String?
        {
            let command = Command()
            guard let (_, data, _) = command.run("doctl", "compute", "droplet", "create", "--image", server.image, "--size", server.configuration, "--region", server.region, "--enable-ipv6", "--enable-monitoring", "--enable-private-networking", "--wait", server.name) else {return nil}

            guard let table = tabulate(string: data.string) else {return nil}
            guard let dropletId = table.search(matchColumn: "Name", withValue: server.name, returnField: "ID") else {return nil}

            return dropletId
        }

        static public func delete(server: Server) -> (Int32, String, String)?
        {
            return DO.Droplet.delete(name: server.name)
        }

        static public func delete(name: String) -> (Int32, String, String)?
        {
            let command = Command()
            guard let (exitCode, data, errData) = command.run("doctl", "compute", "droplet", "delete", "-f", name) else {return nil}
            return (exitCode, data.string, errData.string)
        }

        static public func delete(dropletId: String) -> (Int32, String, String)?
        {
            let command = Command()
            guard let (exitCode, data, errData) = command.run("doctl", "compute", "droplet", "delete", "-f", dropletId) else {return nil}
            return (exitCode, data.string, errData.string)
        }
    }

    public class FloatingIP
    {
        static public func create() -> (Int32, String, String)?
        {
            let command = Command()
            guard let (exitCode, data, errData) = command.run("doctl", "compute", "floating-ip", "create") else {return nil}
            return (exitCode, data.string, errData.string)
        }

        static public func delete(ip: String) -> (Int32, String, String)?
        {
            let command = Command()
            guard let (exitCode, data, errData) = command.run("doctl", "compute", "floating-ip", "delete", "-f", ip) else {return nil}
            return (exitCode, data.string, errData.string)
        }

        static public func assign(ip: String, dropletId: String) -> (Int32, String, String)?
        {
            let command = Command()
            guard let (exitCode, data, errData) = command.run("doctl", "compute", "floating-ip-action", "assign", ip, dropletId) else {return nil}
            return (exitCode, data.string, errData.string)
        }

        static public func unassign(ip: String, dropletId: String) -> (Int32, String, String)?
        {
            let command = Command()
            guard let (exitCode, data, errData) = command.run("doctl", "compute", "floating-ip-action", "assign", ip) else {return nil}
            return (exitCode, data.string, errData.string)
        }

        static public func getAssignment(ip: String) -> String?
        {
            let command = Command()
            guard let (_, data, _) = command.run("doctl", "compute", "floating-ip", "get", ip, "--output", "json") else {return nil}

            guard let table = tabulate(string: data.string) else {return nil}
            guard let dropletId = table.search(matchColumn: "IP", withValue: ip, returnField: "Droplet ID") else {return nil}

            return dropletId
        }
    }
}
