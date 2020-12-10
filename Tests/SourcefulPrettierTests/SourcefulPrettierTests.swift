import XCTest
@testable import SourcefulPrettier

final class SourcefulPrettierTests: XCTestCase {
    
    func testExample() {
//        let prettier = SourceCodePrettier()
//        let xml = prettier.prettify("<test><lol>lkckkckc</lol></test>", parser: .xml)
//        print("__ddd " + (xml ?? "null"))
        
        let jsPrettier = JavaScriptPrettier()
        let js = jsPrettier.prettify("function msg(){ alert(\"Hello Javatpoint\"); }")
        print("__jsjs " + (js ?? "null"))
        
        // This is an example of a functional test case.
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
