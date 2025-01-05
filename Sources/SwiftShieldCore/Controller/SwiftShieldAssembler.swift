import Foundation

public enum SwiftSwiftAssembler {
    public static func generate(
        projectPath: String,
        scheme: String,
        modulesToIgnore: Set<String>,
        namesToIgnore: Set<String>,
        ignorePublic: Bool,
        includeIBXMLs: Bool,
        dryRun: Bool,
        verbose: Bool,
        printSourceKitQueries: Bool,
        outputPath: String?
    ) throws -> SwiftShieldController {
        let logger = Logger(
            verbose: verbose,
            printSourceKit: printSourceKitQueries
        )
        let projectFile = try getProjectFile(projectPath: projectPath.filePath, outputPath: outputPath?.filePath)
        let taskRunner = TaskRunner()
        let infoProvider = SchemeInfoProvider(
            projectFile: projectFile,
            schemeName: scheme,
            taskRunner: taskRunner,
            logger: logger,
            modulesToIgnore: modulesToIgnore,
            includeIBXMLs: includeIBXMLs
        )

        let sourceKit = SourceKit(logger: logger)
        let obfuscator = SourceKitObfuscator(
            sourceKit: sourceKit,
            logger: logger,
            dataStore: .init(),
            namesToIgnore: namesToIgnore,
            ignorePublic: ignorePublic,
            modulesToIgnore: modulesToIgnore
        )

        let interactor = SwiftShieldInteractor(
            schemeInfoProvider: infoProvider,
            logger: logger,
            obfuscator: obfuscator
        )

        return SwiftShieldController(
            interactor: interactor,
            logger: logger,
            dryRun: dryRun
        )
    }
    
    private static func getProjectFile(projectPath: String, outputPath: String?) throws -> File {
        guard let sourceURL = URL(string: projectPath) else {
            throw SwiftSheildError.fileNotFound(projectPath)
        }
        let projectFolder = sourceURL.deletingLastPathComponent()
        if let outputFolderPath = outputPath?.withPathSeparator, outputFolderPath != projectFolder.path.withPathSeparator {
            let projectName = sourceURL.lastPathComponent
            try FileManager.default.copyDirectory(from: projectFolder.path, to: outputFolderPath, clear: true)
            return File(path: outputFolderPath + projectName)
        } else {
            return File(path: projectPath.filePath)
        }
    }
}

