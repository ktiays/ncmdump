# Ncmdump

`Ncmdump` is a Swift Package library for decrypting NetEase Cloud Music `*.ncm` files into `mp3` or `flac` outputs, with metadata repair support.

This repository is library-only. It no longer provides a CLI executable or CMake-based build flow.

## Platform Requirements

- iOS 16.4+
- macOS 13.3+

## Highlights

- Native Swift Package Manager integration
- Reuses the proven C++ decryption core
- Preserves the C compatibility API:
  - `CreateNeteaseCrypt`
  - `Dump`
  - `FixMetadata`
  - `DestroyNeteaseCrypt`
- Provides a Swift-first async API via `NcmConverter`

## Dependency

This package depends on TagLib via SwiftPM and is pinned to:

- Repository: `https://github.com/ktiays/taglib.git`
- Revision: `5f0c9f71c8626e8f85c2df4200680a93d1b574c1`

## Build

```bash
swift build
```

## Swift API Example

```swift
import Ncmdump

let converter = try NcmConverter(inputPath: "/path/to/input.ncm")
try await converter.dump(outputPath: "/path/to/output")
try await converter.fixMetadata()
```

## C API Example

```swift
import CNcmdump

let handle = CreateNeteaseCrypt("/path/to/input.ncm")
let result = Dump(handle, "/path/to/output")
FixMetadata(handle)
DestroyNeteaseCrypt(handle)
```
