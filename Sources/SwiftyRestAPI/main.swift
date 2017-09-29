import SwiftyRestAPICore

let swifty = SwiftyRestAPI()

do {
    try swifty.run()
} catch {
    print("Whoops! An error occurred: \(error)".f.Red)
}
