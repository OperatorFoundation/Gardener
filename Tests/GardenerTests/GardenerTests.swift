import XCTest
@testable import Gardener

final class GardenerTests: XCTestCase
{
    public func testInstallTapeServer()
    {
        let result = Bootstrap.bootstrap(username: "root", host: "206.189.200.18", source: "https://github.com/blanu/TapeServer", branch: "main", target: "TapeServerInstaller")
        
        XCTAssertTrue(result)
    }
    
    public func testSpacesOrTabs()
    {
        guard let table = tabulate(string: "Release:\t20.04", oneSpaceAllowed: false)
        else
        {
            XCTFail()
            return
        }
        
        XCTAssertEqual(table.columns.count, 2)
    }
//    public func testBootstrap()
//    {
//        let result = Bootstrap.bootstrap(username: "root", host: "206.189.200.18")
//        XCTAssert(result)
//    }
}
