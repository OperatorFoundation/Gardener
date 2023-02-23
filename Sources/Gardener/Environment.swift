//
//  Environment.swift
//  
//
//  Created by Joshua Clark on 2/20/23.
//

import Foundation

public class Environment {
    static public func getEnvironmentVariable(key: String) -> String? {
        return ProcessInfo.processInfo.environment[key]
    }
    
    public init() {
        
    }
}
