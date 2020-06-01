import Foundation
import JavaScriptCore

@objc protocol GlobalJSExport : JSExport {
}

@objc class Global : NSObject, GlobalJSExport, JSInsert {
    func insert(_ jsContext: JSContext) {
        jsContext.evaluateScript("var window = global = this;")
    }
}