import Foundation
import Song

public class Gardener: Codable
{
    static public var instance: Gardener = Gardener.load()
    
    static public func load() -> Gardener
    {
        let filename = "config.song"
        let url = URL(fileURLWithPath: filename)
        let song = SongDecoder()
        
        do
        {
            let data = try Data(contentsOf: url)
            let result = try song.decode(Gardener.self, from: data)
            return result
        }
        catch
        {
            return Gardener()
        }
    }
    
    public var swiftPath: String?
    {
        didSet
        {
            Command.swiftPath = swiftPath
        }
    }
    
    public func save()
    {
        let filename = "config.song"
        let url = URL(fileURLWithPath: filename)
        let song = SongEncoder()
        
        do
        {
            let data = try song.encode(self)
            try data.write(to: url)
        }
        catch
        {
            return
        }
    }
}
