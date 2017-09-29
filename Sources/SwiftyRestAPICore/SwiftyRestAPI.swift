import Foundation
import Files
import Swiftline

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

        let fileName = arguments[2]
        //let feature = arguments[1]

        do {
            try FileSystem().createFile(at: fileName)
            print("\(fileName) created at \(Folder.current)".f.Green )
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
