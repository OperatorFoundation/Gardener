import XCTest
@testable import Gardener

final class GardenerTests: XCTestCase
{
    public func testInstallTapeServer()
    {
        let result = Bootstrap.bootstrap(username: "root", host: "206.189.200.18", source: "https://github.com/blanu/TapeServer", branch: "main", target: "TapeServerInstaller")
        
        XCTAssertTrue(result)
    }
    
    public func testCommandGoVersion()
    {
        let result = Go().version()
        
        XCTAssertNotNil(result)
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
    
    public func testTabulateWithRowHeaders()
    {
        let tableString = "Release:\t20.04"
        
        guard let table = tabulate(string: tableString, headers: true, rowHeaders: true, oneSpaceAllowed: false)
        else
        {
            XCTFail()
            return
        }
        
        XCTAssertEqual(table.rows.count, 1)
        
        guard let statusIndex = table.findRowIndex(label: "Release:")
        else
        {
            XCTFail()
            return
        }
        
        let statusRow = table.rows[statusIndex]
        XCTAssertEqual(statusRow.fields[0], "20.04")
    }
    
    public func testParseHttpLikeHeader()
    {
        let headerString = """
        Date: 2021-04-27 17:53:53 +0000
                  Hash: 007126bf5848ba6fe8c43ba055be7ac2f175
            LogFileURL: https://osxapps-ssl.itunes.apple.com/itunes-assets/
                Status: success
           Status Code: 0
        Status Message: Package Approved
        """
        
        let newDict = parseHttpLikeHeader(headerString: headerString)
        XCTAssert(!newDict.isEmpty)
        XCTAssertEqual(newDict["Status"], "success")
    }
//    public func testBootstrap()
//    {
//        let result = Bootstrap.bootstrap(username: "root", host: "206.189.200.18")
//        XCTAssert(result)
//    }
}
