import Foundation
import XCTest
@testable import Ncmdump
import CNcmdump

final class NcmdumpTests: XCTestCase {
    private func makeFixtureCopy() throws -> URL {
        let sourceURL = try XCTUnwrap(Bundle.module.url(forResource: "test", withExtension: "ncm"))

        let fileManager = FileManager.default
        let tempRoot = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        try fileManager.createDirectory(at: tempRoot, withIntermediateDirectories: true)

        let targetURL = tempRoot.appendingPathComponent("test.ncm", isDirectory: false)
        try fileManager.copyItem(at: sourceURL, to: targetURL)

        return targetURL
    }

    private func makeOutputDirectory() throws -> URL {
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)
        return outputURL
    }

    func testSwiftActorConvertsAndFixesMetadata() async throws {
        let fixtureURL = try makeFixtureCopy()
        let outputDirectory = try makeOutputDirectory()

        let converter = try NcmdumpConverter(inputPath: fixtureURL.path)
        try await converter.dump(outputPath: outputDirectory.path)
        try await converter.fixMetadata()

        let files = try FileManager.default.contentsOfDirectory(
            at: outputDirectory,
            includingPropertiesForKeys: [.fileSizeKey],
            options: [.skipsHiddenFiles]
        )

        XCTAssertFalse(files.isEmpty)

        let audioFile = files.first {
            let ext = $0.pathExtension.lowercased()
            return ext == "mp3" || ext == "flac"
        }
        XCTAssertNotNil(audioFile)

        if let audioFile {
            let attributes = try FileManager.default.attributesOfItem(atPath: audioFile.path)
            let fileSize = attributes[.size] as? NSNumber
            XCTAssertGreaterThan(fileSize?.intValue ?? 0, 0)
        }
    }

    func testInitWithMissingFileThrows() throws {
        XCTAssertThrowsError(try NcmdumpConverter(inputPath: "/tmp/not-existing-file.ncm")) { error in
            guard case NcmdumpError.createFailed = error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
        }
    }

    func testCInterfaceStillWorks() throws {
        let fixtureURL = try makeFixtureCopy()
        let outputDirectory = try makeOutputDirectory()

        let handle = fixtureURL.path.withCString { pointer in
            CreateNeteaseCrypt(pointer)
        }
        XCTAssertNotNil(handle)

        guard let handle else {
            return
        }

        defer {
            DestroyNeteaseCrypt(handle)
        }

        let dumpResult = outputDirectory.path.withCString { pointer in
            Dump(handle, pointer)
        }
        XCTAssertEqual(dumpResult, 0)

        FixMetadata(handle)
        XCTAssertEqual(GetLastErrorCode(handle), Int32(NCMDUMP_ERROR_NONE))
    }
}
