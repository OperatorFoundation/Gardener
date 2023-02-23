//
//  Github.swift
//  
//
//  Created by Dr. Brandon Wiley on 1/30/23.
//

import Foundation

import Chord
import OctoKit

public class Github
{
    let token: String
    let octokit: Octokit

    public init(token: String)
    {
        self.token = token

        let config = TokenConfiguration(self.token)
        self.octokit = Octokit(config)
    }

    public func repositories() throws -> [Repository]
    {
        return try AsyncAwaitThrowingSynchronizer<[Repository]>.sync
        {
            return try await self.octokit.repositories()
        }
    }
}
