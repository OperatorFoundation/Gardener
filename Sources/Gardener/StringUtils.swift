//
//  StringUtils.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/2/20.
//

import Foundation

extension String
{
    func findLine(pattern: String) -> String?
    {
        let lines = self.split(separator: "\n")
        for line in lines
        {
            if self.range(of: pattern, options: .regularExpression) != nil
            {
                return String(line)
            }
        }
        
        return nil
    }
    
    func extract(pattern: String) -> String?
    {
        guard let range = self.range(of: pattern, options: .regularExpression) else {return nil}
        let substring = String(self[range])
        return substring
    }
}
