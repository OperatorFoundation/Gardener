#if os(macOS)
import XCTest
@testable import Gardener

final class GardenerTests: XCTestCase
{
    public func testFetchApplicationSupportDirectorySubDirectories() {
        let appSupportDir = File.applicationSupportDirectory()
        guard let contents = File.contentsOfDirectory(atPath: appSupportDir.path) else {
            XCTFail()
            return
        }
        
        let contentsIndex = contents.enumerated()
        for (_, subDir) in contentsIndex {
            if appSupportDir.appendingPathComponent(subDir).hasDirectoryPath {
                print("\(subDir) is a directory")
            } else {
                print("\(subDir) is not a directory")
            }
        }
    }
    
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

    public func testHomebrewIsInstalled()
    {
        let correct = false
        let maybeResult = Homebrew.isInstalled("fakepackage1234")
        guard let result = maybeResult else
        {
            XCTFail()
            return
        }

        XCTAssertEqual(result, correct)
    }

    public func testHomebrewInstallIsInstalled()
    {
        let correct = true

        guard let (_, _, _) = Homebrew.install("swiftlint") else
        {
            XCTFail()
            return
        }

        let maybeResult = Homebrew.isInstalled("swiftlint")
        guard let result = maybeResult else
        {
            XCTFail()
            return
        }

        XCTAssertEqual(result, correct)
    }

    public func testIsDirectory()
    {
        guard File.touch("testfile") else
        {
            XCTFail()
            return
        }
        guard File.makeDirectory(atPath: "testdir") else
        {
            XCTFail()
            return
        }

        XCTAssertFalse(File.isDirectory("testfile"))
        XCTAssertTrue(File.isDirectory("testdir"))

        guard File.delete(atPath: "testfile") else
        {
            XCTFail()
            return
        }

        guard File.delete(atPath: "testdir") else
        {
            XCTFail()
            return
        }
    }

    func testFindFiles() throws
    {
        let home = File.homeDirectory()
        let dir = home.appendingPathComponent("Gardener")
        let files = File.findFiles(dir)
        print(files)
    }

    func testFindFilesGlob() throws
    {
        let home = File.homeDirectory()
        let dir = home.appendingPathComponent("Gardener")
        let files = File.findFiles(dir, pattern: "*.swift")
        print(files)
    }
}
#endif
