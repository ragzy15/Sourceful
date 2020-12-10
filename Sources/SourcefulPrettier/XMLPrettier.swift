//
//  XMLPrettier.swift
//  SourcefulPrettier
//
//  Created by Raghav Ahuja on 11/12/20.
//

import Foundation
import JavaScriptCore

public final class XMLPrettier {
    
    private var vkBeautifier: JSValue?
    
    public init() {
        
        let jsContext = JSContext()!
        let window = JSValue(newObjectIn: jsContext)
        
        jsContext.setObject(window, forKeyedSubscript: "window" as NSString)
        
        do {
            if let vkBeautifierPath = Bundle.module.path(forResource: "vkbeautify", ofType: "js") {
                let vkBeautifierJs = try String(contentsOfFile: vkBeautifierPath)
                let vkValue = jsContext.evaluateScript(vkBeautifierJs)
                
                if vkValue?.toBool() == true, let vkBeautifierJS = window?.objectForKeyedSubscript("vkbeautify") {
                    vkBeautifier = vkBeautifierJS
                } else {
                    vkBeautifier = nil
                }
            } else {
                vkBeautifier = nil
            }
        } catch let error as NSError {
            print(error)
            vkBeautifier = nil
        }
    }
    
    public func prettify(_ code: String) -> String? {
        #if os(macOS)
        do {
            let doc = try XMLDocument(xmlString: code)
            try doc.validate()
            let data = doc.xmlData(options: .nodePrettyPrint)
            let xmlPretty = String(data: data, encoding: .utf8)
            return xmlPretty
        } catch {
            print(error as NSError)
            return nil
        }
        #else
        guard let result = vkBeautifier?.invokeMethod("xml", withArguments: [code])?.toString(), result != "undefined" else {
            return nil
        }
        
        return result
        #endif
    }
}
