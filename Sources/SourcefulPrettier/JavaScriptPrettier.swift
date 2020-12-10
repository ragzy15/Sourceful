//
//  JavaScriptPrettier.swift
//  SourcefulPrettier
//
//  Created by Raghav Ahuja on 11/12/20.
//

import Foundation
import JavaScriptCore

public final class JavaScriptPrettier {
    
    private var context = JSContext()!
    
    public init() {
        let bundle = Bundle.module
        let prettierLibs = [
            "beautify",
            "beautify-css",
            "beautify-html",
        ]
        
        prettierLibs.forEach {
            if let url = bundle
                .path(forResource: $0, ofType: "js") {
                let script = try? String(contentsOfFile: url)
                context.evaluateScript(script)
            }
        }
    }
    
    public func prettify(_ code: String) -> String? {
        let prettifyFn = context.objectForKeyedSubscript("js_beautify")!
        
        guard let result = prettifyFn
            .call(withArguments: [code]).toString(),
            result != "undefined" else {
            return nil
        }
        
        return result
    }
}
