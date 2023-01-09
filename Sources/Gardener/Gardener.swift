#if os(macOS)
import Foundation

public class Gardener: Codable
{
    static public let instance = Gardener()

    public var swiftPath: String?
    {
        didSet
        {
            Command.swiftPath = swiftPath
        }
    }
}
#endif
