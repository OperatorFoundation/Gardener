//
//  Swift.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/2/20.
//

import Foundation
import Datable

public class Go
{
    var command = Command()

    // FIXME - copied from Swift, needs to be rewritten
    static public func install(os: String) -> Bool
    {
        let baseURL = URL(string: "https://swift.org")!
        let releasesPageURL: URL = baseURL.appendingPathComponent("/download/#releases")
        guard let releasesPage = try? String(contentsOf: releasesPageURL) else {return false}

        guard let line = releasesPage.findLine(pattern: "ubuntu\(os).tar.gz") else {return false}
        guard let untrimmedDownloadPath = line.extract(pattern: #"<a href=\"([^\"]+)\">"#) else {return false}
        let downloadPath = untrimmedDownloadPath.trimmingCharacters(in: CharacterSet(arrayLiteral: "\""))
            
        let downloadURL = baseURL.appendingPathComponent(downloadPath)
        let filename = downloadURL.lastPathComponent
        let outputURL = URL(fileURLWithPath: filename)

        guard Downloader.download(from: downloadURL, to: outputURL) else {return false}
        
        let command = Command()
        guard let (exitCode, data, errData) = command.run("tar", "zxvf", filename) else {return false}
        guard exitCode == 0 else {return false}

        let tarline = String(data.string.split(separator: "\n")[0])
        let dirname = String(tarline.split(separator: " ")[8])
        Gardener.instance.swiftPath = dirname
        
        return true
    }
    
    public func cd(_ path: String) -> Bool
    {
        return command.cd(path)
    }
    
    public func build() -> (Int32, Data, Data)?
    {
        return command.run("go", "build")
    }
    
    public func test() -> (Int32, Data, Data)?
    {
        return command.run("go", "test")
    }

    // FIXME - needs program name argument
    public func run() -> (Int32, Data, Data)?
    {
        return command.run("go", "run")
    }
}