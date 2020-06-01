import Foundation
import JavaScriptCore

@objc enum ConsoleLevel : Int {
    case log, info, warn, error
}
@objc protocol ConsoleJSExport : JSExport {
    func output(_ level: ConsoleLevel, arguments: [AnyObject])
}

@objc class Console : NSObject, ConsoleJSExport, JSInsert {
    let levelDictionary : [ConsoleLevel : String] = [
        .log: "",
        .info: "[info]",
        .warn: "[WARN]",
        .error: "[ERROR]"
    ]

    func output(_ level: ConsoleLevel, arguments: [AnyObject]) {
        var levelOutput = levelDictionary[level]
        if levelOutput == nil {
            levelOutput = ""
        }

        print("[JSCotextFoundation]" + levelOutput!, terminator: " ")
        for argument in arguments {
            print(argument, terminator: " ")
        }


        // new line
        print("")
    }

    func insert(_ jsContext: JSContext) {
        jsContext.setObject(self, forKeyedSubscript:"$console" as (NSCopying & NSObjectProtocol))
        jsContext.evaluateScript(
            "var console = {" +
                "log: function() { $console.outputArguments(0, arguments); }," +
                "info: function() { $console.outputArguments(1, arguments); }," +
                "warn: function() { $console.outputArguments(2, arguments); }," +
                "error: function() { $console.outputArguments(3, arguments); }" +
            "};" +
            "if (global) { global.console = console; }"
        )
    }
}

@objc protocol HttpJSExport : JSExport {
    func get(_ urlString: String) -> String
}

@objc class Http : NSObject, HttpJSExport, JSInsert {
    // https://stackoverflow.com/questions/39985984/how-to-return-http-result-synchronously-in-swift3
    func get(_ urlString: String) -> String {
        let url = URL(string: urlString)!
        var dataStringOrNil: String?
        let semaphore = DispatchSemaphore(value: 0)

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            defer {
                semaphore.signal()
            }

            guard let data = data, error == nil else {
                print("error")
                return
            }

            dataStringOrNil = String(data: data, encoding: .utf8)
        }

        task.resume()
        semaphore.wait()

        guard let dataString = dataStringOrNil else {
            return ""
        }

        return dataString
    }

    func insert(_ jsContext: JSContext) {
        jsContext.setObject(self, forKeyedSubscript:"http" as (NSCopying & NSObjectProtocol))
        jsContext.evaluateScript("if (global) { global.http = http; }")
    }
}