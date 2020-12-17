//
//  Files.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/2/20.
//

import Foundation

public class File
{
    static public func get(_ path: String) -> Data?
    {
        return FileManager.default.contents(atPath: path)
    }
    
    static public func put(_ path: String, contents: Data) -> Bool
    {
        let url = URL(fileURLWithPath: path)
        
        do
        {
            try contents.write(to: url)
        }
        catch
        {
            return false
        }
        
        return true
    }

    static public func exists(_ path: String) -> Bool
    {
        return FileManager.default.fileExists(atPath: path)
    }
}