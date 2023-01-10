//
//  Linux.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/3/20.
//
#if os(iOS) || os(watchOS) || os(tvOS)
#else
import Foundation
import Datable

public class Linux
{
    static public func version() -> String?
    {
        let command = Command()
        guard let (result, data, _) = command.run("lsb_release", "-r") else {return nil}
        guard result == 0 else {return nil}
        
//        let command = Command()
//        guard let (_, data, _) = command.run("lsb_release", "-a") else {return nil}
//        let output = data.string
//        guard let line = output.findLine(pattern: #"Release:"#) else {return nil}
//        return line.extract(pattern: #"Release:[ ]+([^ ])+"#)
        return parseLSBtoVersionNumber(lsbString: data.string)
    }
    
    static public func parseLSBtoVersionNumber(lsbString: String) -> String?
    {
        guard let table = tabulate(string: lsbString, headers: false, oneSpaceAllowed: false) else {return nil}
        return table.columns[1].fields[0]
    }
    
}
#endif
