@testable import SwiftShieldCore
import XCTest

final class IBXMLObfuscationWrapperTests: XCTestCase {
    let fileBasepath = FileManager.default.currentDirectoryPath
    
    private func setupXMLObfuscation() throws -> String {
        let xmlView = """
    <?xml version="1.0" encoding="UTF-8"?>
    <objects>
    <placeholder placeholderIdentifier="IBFilesOwner" id="-1" userLabel="File's Owner" customClass="TestViewViewController" customModule="SwiftSheildTestApp" customModuleProvider="target">
        <connections>
            <outlet property="button" destination="WOO-pi-Txv" id="qza-Jb-OAV"/>
            <outlet property="view" destination="iN0-l3-epB" id="gAa-O2-yVS"/>
        </connections>
    </placeholder>
    <placeholder placeholderIdentifier="IBFirstResponder" id="-2" customClass="UIResponder"/>
    <view contentMode="scaleToFill" id="iN0-l3-epB">
        <subviews>
            <button opaque="NO" contentMode="scaleToFill" contentHorizontalAlignment="center" contentVerticalAlignment="center" buttonType="system" lineBreakMode="middleTruncation" translatesAutoresizingMaskIntoConstraints="NO" id="WOO-pi-Txv">
                <connections>
                    <action selector="IBOBXX2:" destination="-1" eventType="touchUpInside" id="ZY7-HI-2YE"/>
                </connections>
            </button>
        </subviews>
    </view>
    </objects>
    """
        let filePath = fileBasepath + "/xmlView.xml"
        try? xmlView.write(toFile: filePath, atomically: true, encoding: .utf8)
        return filePath
    }
    
    func testXMLObfuscation() throws {
        let filePath = try setupXMLObfuscation()
        let xmlWrapper = IBXMLObfuscationWrapper(obfuscationDictionary: [
            "TestViewViewController" : "IBOBXX1",
            "buttonClicked": "IBOBXX2"
        ])
        let resultXML = try xmlWrapper.obfuscate(file: File(path: filePath))
        let obfuscatedXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <objects>
            <placeholder placeholderIdentifier="IBFilesOwner" id="-1" userLabel="File's Owner" customClass="IBOBXX1" customModule="SwiftSheildTestApp" customModuleProvider="target">
                <connections>
                    <outlet property="button" destination="WOO-pi-Txv" id="qza-Jb-OAV"/>
                    <outlet property="view" destination="iN0-l3-epB" id="gAa-O2-yVS"/>
                </connections>
            </placeholder>
            <placeholder placeholderIdentifier="IBFirstResponder" id="-2" customClass="UIResponder"/>
            <view contentMode="scaleToFill" id="iN0-l3-epB">
                <subviews>
                    <button opaque="NO" contentMode="scaleToFill" contentHorizontalAlignment="center" contentVerticalAlignment="center" buttonType="system" lineBreakMode="middleTruncation" translatesAutoresizingMaskIntoConstraints="NO" id="WOO-pi-Txv">
                        <connections>
                            <action selector="IBOBXX2:" destination="-1" eventType="touchUpInside" id="ZY7-HI-2YE"/>
                        </connections>
                    </button>
                </subviews>
            </view>
        </objects>
        """
        XCTAssert(resultXML == obfuscatedXML)
        try FileManager.default.removeItem(atPath: filePath)
    }
    
    func testXIBObfuscation() throws {
        let filePath = Bundle.module.path(forResource: "TestData/TestView", ofType: "xib")!
        let xmlWrapper = IBXMLObfuscationWrapper(obfuscationDictionary: [
            "TestViewViewController" : "IBOBXX1",
            "buttonClicked": "IBOBXX2",
            "P2MSButton": "IBOBXX3",
            "P2MSTextField": "IBOBXX4",
            "textFieldChanged": "IBOBXX5",
            "P2MSTapGesture": "IBOBXX6",
            "tapped": "IBOBXX7",
            "P2MSLayoutConstraint": "IBOBXX8"
        ])
        let resultXML = try xmlWrapper.obfuscate(file: File(path: filePath))
        let verifyXML = try File(path: Bundle.module.path(forResource: "TestData/TestViewObfuscated", ofType: "xib")!).read()
        XCTAssert(resultXML.trimmingCharacters(in: .whitespacesAndNewlines) == verifyXML.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func testStoryboardObfuscation() throws {
        let filePath = Bundle.module.path(forResource: "TestData/Main", ofType: "storyboard")!
        let xmlWrapper = IBXMLObfuscationWrapper(obfuscationDictionary: [
            "ViewController" : "IBOBXX1",
            "buttonClicked": "IBOBXX2",
            "P2MSStoryboardSegue": "IBOBXX3",
            "NewViewController" : "IBOBXX4",
            "switchValueChanged": "IBOBXX5",
            "P2MSButton": "IBOBXX6",
            "btnClicked": "IBOBXX7",
            "AnotherViewController": "IBOBXX8",
            "P2MSLayoutConstraint": "IBOBXX9",
            "P2MSCustomBaseView": "IBOBXX10",
            "someConnection": "IBOBXX11"
        ])
        let resultXML = try xmlWrapper.obfuscate(file: File(path: filePath))
        let verifyXML = try File(path: Bundle.module.path(forResource: "TestData/MainObfuscated", ofType: "storyboard")!).read()
        print(resultXML)
        print(verifyXML)
        XCTAssert(resultXML.trimmingCharacters(in: .whitespacesAndNewlines) == verifyXML.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}


