//
//  File 2.swift
//  
//
//  Created by Mafalda on 4/5/21.
//
#if os(iOS) || os(watchOS) || os(tvOS)
#else
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

    func build(path: String) throws -> (exitCode: Int32, resultData: Data, errorData: Data)?
    {
        guard File.pushd(path) else
        {
            throw XCodeError.cdFailed(path)
        }

        let result = self.command.run("xcodebuild")

        let _ = File.popd()

        return result
    }

    func run(path: String) throws
    {
        let url = URL(fileURLWithPath: path)
        let projectName = url.lastPathComponent

        guard File.pushd(path) else
        {
            throw XCodeError.cdFailed(path)
        }

        let _ = self.command.run("build/Release/\(projectName).app")

        let _ = File.popd()
    }
}

public enum XCodeError: Error
{
    case cdFailed(String)
}

#endif
