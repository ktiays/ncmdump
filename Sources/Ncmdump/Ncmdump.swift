import Foundation
import CNcmdump

private final class NcmHandleBox: @unchecked Sendable {
    var raw: OpaquePointer?

    init(raw: OpaquePointer) {
        self.raw = raw
    }

    deinit {
        if let raw {
            DestroyNeteaseCrypt(raw)
        }
    }
}

public enum NcmError: Error, Equatable {
    case createFailed(path: String)
    case invalidHandle
    case dumpFailed(code: Int32, message: String)
    case fixMetadataFailed(code: Int32, message: String)
}

public actor NcmConverter {
    private let handleBox: NcmHandleBox

    public init(inputPath: String) throws {
        let createdHandle = inputPath.withCString { pointer in
            CreateNeteaseCrypt(pointer)
        }

        guard let createdHandle else {
            throw NcmError.createFailed(path: inputPath)
        }

        self.handleBox = NcmHandleBox(raw: createdHandle)
    }

    public func dump(outputPath: String? = nil) throws {
        guard let handle = handleBox.raw else {
            throw NcmError.invalidHandle
        }

        let dumpResult: Int32
        if let outputPath {
            dumpResult = outputPath.withCString { pointer in
                Dump(handle, pointer)
            }
        } else {
            dumpResult = Dump(handle, nil)
        }

        guard dumpResult == 0 else {
            let code = Int32(GetLastErrorCode(handle))
            let message = String(cString: GetLastErrorMessage(handle))
            throw NcmError.dumpFailed(code: code, message: message)
        }
    }

    public func fixMetadata() throws {
        guard let handle = handleBox.raw else {
            throw NcmError.invalidHandle
        }

        FixMetadata(handle)

        let code = Int32(GetLastErrorCode(handle))
        guard code == Int32(NCMDUMP_ERROR_NONE) else {
            let message = String(cString: GetLastErrorMessage(handle))
            throw NcmError.fixMetadataFailed(code: code, message: message)
        }
    }
}
