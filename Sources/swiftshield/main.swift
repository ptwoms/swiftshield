import ArgumentParser
import Foundation
import SwiftShieldCore

struct Swiftshield: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "SwiftShield 4.2.1",
        subcommands: [Obfuscate.self, Deobfuscate.self]
    )
}

extension Swiftshield {
    struct Obfuscate: ParsableCommand {
        @Option(name: .shortAndLong, help: "The path to your app's main .xcodeproj/.xcworkspace file.")
        var projectFile: String

        @Option(name: .shortAndLong, help: "The main scheme from the project to build.")
        var scheme: String
        
        @Option(help: "A list of targets, separated by a comma, that should NOT be obfuscated.")
        var ignoreTargets: String?
        
        @Option(help: "A list of names, separated by a comma, that should NOT be obfuscated.")
        var ignoreNames: String?

        @Flag(help: "Don't obfuscate content that is 'public' or 'open' (a.k.a 'SDK Mode').")
        var ignorePublic: Bool = false
        
        @Flag(help: "obfuscate storyboard and xib files. (experimental)")
        var includeIbxmls: Bool = false

        @Flag(name: .shortAndLong, help: "Prints additional information.")
        var verbose: Bool = false

        @Flag(name: .shortAndLong, help: "Does not actually overwrite the files.")
        var dryRun: Bool = false
        
        @Option(help: "Output path for the obfuscated project. Default to in-place replacement. Make sure that all source codes are in the project directory")
        var outputPath: String?

        @Flag(help: "Prints SourceKit queries. Note that they are huge, so use this only for bug reports and development!")
        var printSourcekit: Bool = false

        mutating func run() throws {
            let modulesToIgnore = Set((self.ignoreTargets ?? "").components(separatedBy: ","))
            let namesToIgnore = Set((self.ignoreNames ?? "").components(separatedBy: ","))
            let runner = try SwiftSwiftAssembler.generate(
                projectPath: self.projectFile, scheme: self.scheme,
                modulesToIgnore: modulesToIgnore,
                namesToIgnore: namesToIgnore,
                ignorePublic: self.ignorePublic,
                includeIBXMLs: self.includeIbxmls,
                dryRun: self.dryRun,
                verbose: self.verbose,
                printSourceKitQueries: self.printSourcekit,
                outputPath: self.outputPath
            )
            try runner.run()
        }
    }
}

extension Swiftshield {
    struct Deobfuscate: ParsableCommand {
        @Option(name: .shortAndLong, help: "The path to the crash file.")
        var crashFile: String

        @Option(name: [.long, .customShort("m")], help: "The path to the previously generated conversion map.")
        var conversionMap: String

        func run() throws {
            let runner = Deobfuscator()
            try runner.deobfuscate(crashFilePath: crashFile, mapPath: conversionMap)
        }
    }
}

Swiftshield.main()
