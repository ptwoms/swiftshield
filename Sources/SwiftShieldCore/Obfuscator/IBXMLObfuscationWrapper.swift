//
//  IBXMLObfuscationWrapper.swift
//  

import Foundation

final class IBXMLObfuscationWrapper {
    private let obfuscationDictionary: [String: String]
    
    init(obfuscationDictionary: [String: String]) {
        self.obfuscationDictionary = obfuscationDictionary
    }
    
    func obfuscate(file: File) throws -> String {
        let xmlDoc = try XMLDocument(contentsOf: URL(fileURLWithPath: file.path), options: XMLNode.Options())
        guard let rootElement = xmlDoc.rootElement() else { return "" }
        obfuscateIBXML(element: rootElement)
        let origStr = try file.read()
        var newUIFile = xmlDoc.xmlString(options: [.nodePrettyPrint, .nodeCompactEmptyElement])
        let xmlLineRegex = "<\\?xml version=.*?\\?>"
        if let oldXMLRange = origStr.range(of: xmlLineRegex, options: .regularExpression) {
            newUIFile.replaceFirst(regex: xmlLineRegex, with: String(origStr[oldXMLRange]))
        }
        return newUIFile
    }
    
    private func obfuscateIBXML(element: XMLElement) {
        if let attribElement = element.attribute(forName: "customClass"), let attribStr = attribElement.stringValue, !attribStr.isEmpty, let obfuscatedClassName = obfuscationDictionary[attribStr], !obfuscatedClassName.isEmpty {
            attribElement.stringValue = obfuscatedClassName
        }
        if element.name == "action", let selectorElement = element.attribute(forName: "selector"), element.parent?.name == "connections", let selectorStr = selectorElement.stringValue, !selectorStr.isEmpty {
            if selectorStr.contains(":") {
                var selectorComps = selectorStr.components(separatedBy: ":")
                if let firstSelectorName = selectorComps.first, !firstSelectorName.isEmpty, let obfuscatedName = obfuscationDictionary[firstSelectorName], !obfuscatedName.isEmpty {
                    selectorComps[0] = obfuscatedName
                    selectorElement.stringValue = selectorComps.joined(separator: ":")
                }
            }else{
                if let obfuscatedName = obfuscationDictionary[selectorStr], !obfuscatedName.isEmpty {
                    selectorElement.stringValue = obfuscatedName
                }
            }
        }
        for child in element.children ?? [] {
            guard let childElement = child as? XMLElement else { continue }
            obfuscateIBXML(element: childElement)
        }
    }
}
