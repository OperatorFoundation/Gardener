//
//  File 2.swift
//  
//
//  Created by Mafalda on 4/5/21.
//
#if os(macOS)
import Foundation

public class XCode
{
    var command: Command
    
    public init()
    {
        command = Command()
    }
    
    func requestNotarizationStatus(uuid: String, username: String, password: String) -> (exitCode: Int32, resultData: Data, errorData: Data)?
    {
        return command.run("xcrun",
                            "altool",
                            "--notarization-info", uuid,
                            "--username", username,
                            "--password", password)
    }
}
#endif
