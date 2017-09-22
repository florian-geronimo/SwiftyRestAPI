import Foundation
import Files

public final class SwiftyRestAPI {
    private let arguments: [String]

    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    public func run() throws {

      guard arguments.count > 1 else {
          throw Error.missingFeatureConvert
      }

      guard arguments[1] == "convert" else {
          throw Error.missingFeatureConvert
      }

      guard arguments.count > 2 else {
          throw Error.missingFileName
      }


        // The first argument is the execution path
        let fileName = arguments[2]

        do {
            try FileSystem().createFile(at: fileName)
        } catch {
            throw Error.failedToCreateFile
        }
    }
}

public extension SwiftyRestAPI {
    enum Error: Swift.Error {
        case missingFileName
        case failedToCreateFile
        case missingFeatureConvert
    }
}
