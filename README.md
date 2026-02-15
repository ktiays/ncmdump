# Ncmdump

`Ncmdump` 是一个纯 Swift Package 形式的库，用于将网易云音乐 `*.ncm` 文件解密为 `mp3/flac`，并可修复音频元数据。

本仓库不再提供可执行文件（CLI）与 CMake 构建，仅提供库能力。

最低平台版本：`iOS 16.4`、`macOS 13.3`。

## 特性

- Swift Package Manager 原生集成
- 复用原有 C++ 解密核心算法
- 保留基础 C 接口（`CreateNeteaseCrypt` / `Dump` / `FixMetadata` / `DestroyNeteaseCrypt`）
- 提供 Swift `actor` 封装（`NcmdumpConverter`）

## 依赖

本包依赖 TagLib 的 SwiftPM 包（固定到指定 commit）：

- 仓库：`https://github.com/ktiays/taglib.git`
- revision：`5f0c9f71c8626e8f85c2df4200680a93d1b574c1`

## 构建

```bash
swift build
```

## Swift 用法

```swift
import Ncmdump

let converter = try NcmdumpConverter(inputPath: "/path/to/test.ncm")
try await converter.dump(outputPath: "/path/to/output")
try await converter.fixMetadata()
```

## C 接口用法

```swift
import CNcmdump

let handle = CreateNeteaseCrypt("/path/to/test.ncm")
let result = Dump(handle, "/path/to/output")
FixMetadata(handle)
DestroyNeteaseCrypt(handle)
```

## 测试

```bash
swift test
```

测试资源使用 `Tests/NcmdumpTests/Resources/test.ncm`。
