import XCTest
@testable import Gardener

final class GardenerTests: XCTestCase
{
    public func testInstallTapeServer()
    {
        Bootstrap.bootstrap(username: "root", host: "206.189.200.18", source: "https://github.com/blanu/TapeServer", branch: "main", target: "TapeServerInstaller")
    }
//    public func testBootstrap()
//    {
//        let result = Bootstrap.bootstrap(username: "root", host: "206.189.200.18")
//        XCTAssert(result)
//    }
}
