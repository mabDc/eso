import FlutterMacOS
import JavaScriptCore


public class SwiftFlutterJsPlugin: NSObject, FlutterPlugin {
    private var jsEngineMap = [Int: JSContextFoundation]()
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "io.abner.flutter_js", binaryMessenger: registrar.messenger)
        let instance = SwiftFlutterJsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    // 字典或者数组 转 JSON
    private func dataTypeTurnJson(element:AnyObject) -> String {
        let jsonData = try! JSONSerialization.data(withJSONObject: element, options: JSONSerialization.WritingOptions.prettyPrinted)
        let str = String(data: jsonData, encoding: String.Encoding.utf8)!
        return str
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initEngine":
            let engineId = call.arguments as! Int
            jsEngineMap[engineId] = JSContextFoundation()
            result(engineId)
        case "evaluate":
            let argsMap = call.arguments as! NSDictionary
            let command: String = argsMap.value(forKey: "command") as! String
            let engineId: Int = argsMap.value(forKey: "engineId") as! Int

            if let jsEngine = jsEngineMap[engineId] {
                jsEngine.exceptionHandler = { _, exception in
                    let exceptionDictionary = exception?.toDictionary()
                    print("[JSCotextFoundation][Exception] \(String(describing: exception)) at line \(String(describing: exceptionDictionary?["line"])):\(String(describing: exceptionDictionary?["column"]))")
                    result(FlutterError(code: "EvaluateError",
                                        message: String(describing: exception),
                                        details: nil))
                }

                let resultJsValue: JSValue = jsEngine.evaluateScript(command)
                if resultJsValue.isArray {
                    result(resultJsValue.toArray())
                } else if resultJsValue.isObject {
                    result(resultJsValue.toDictionary())
                } else {
                    result(resultJsValue.toString())
                }

            } else {
                result(FlutterError(code: "EvaluateError",
                                    message: "jsEngine was not found",
                                    details: nil))
            }
        case "close":
            let argsMap = call.arguments as! NSDictionary
            let engineId: Int = argsMap.value(forKey: "engineId") as! Int
            jsEngineMap.removeValue(forKey: engineId)
            result(true)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
