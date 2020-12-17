//
//  Linux.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/3/20.
//

import Foundation
import Datable

public class Linux
{
    static public func version() -> String?
    {
        let command = Command()
        guard let (_, data, errData) = command.run("lsb_release", "-a") else {return nil}
        let output = data.string
        guard let line = output.findLine(pattern: #"Release:"#) else {return nil}
        return line.extract(pattern: #"Release:[ ]+([^ ])+"#)
    }
    
    
}
