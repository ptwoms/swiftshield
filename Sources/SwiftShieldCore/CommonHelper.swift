//
//  CommonHelper.swift
//  swiftshield
//
//  Created by Pyae Phyo Myint Soe on 4/1/25.
//
import Foundation

enum SwiftSheildError: Error {
    case fileNotFound(String)
}

extension FileManager {
    func clearDirectory(at path: String) throws {
        let folderPath = path.withPathSeparator
        try contentsOfDirectory(atPath: folderPath).forEach {
            try? removeItem(atPath: folderPath + $0)
        }
    }

    func copyDirectory(from source: String, to destination: String, clear: Bool = true) throws {
        if clear {
            try clearDirectory(at: destination)
        }
        let destFolder = destination.withPathSeparator
        let sourceFolder = source.withPathSeparator
        try contentsOfDirectory(atPath: sourceFolder).forEach {
            try copyItem(atPath: sourceFolder + $0, toPath: destFolder + $0)
        }
    }
}

