//
//  Downloader.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/2/20.
//

import Foundation
import Chord

public class Downloader
{
    let from: URL
    let to: URL

    static public func download(from: URL, to: URL) -> Bool
    {
        let downloader = Downloader(from: from, to: to)
        return Synchronizer.sync(downloader.async)
    }
    
    public init(from: URL, to: URL)
    {
        self.from = from
        self.to = to
    }
    
    func async(_ callback: @escaping (Bool) -> Void)
    {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)

        session.downloadTask(with: self.from)
        {
            (maybeDownloadTaskURL, maybeResponse, maybeError) in
            
            guard maybeError == nil else
            {
                callback(false)
                return
            }
            
            guard let downloadTaskURL = maybeDownloadTaskURL else
            {
                callback(false)
                return
            }

            do
            {
                try FileManager.default.copyItem(at: downloadTaskURL, to: self.to)
            }
            catch (let writeError)
            {
                print("error writing file \(self.to) : \(writeError)")
                callback(false)
                return
            }
            
            callback(true)
        }
    }
}
