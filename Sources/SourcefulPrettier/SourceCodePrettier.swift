//
//  SourceCodePrettier.swift
//  SourcefulPrettier
//
//  Created by Raghav Ahuja on 11/12/20.
//

import JavaScriptCore

public final class SourceCodePrettier {
    
    public enum Language: String {
        case flow
        case babel
        case babelFlow = "babel-flow"
        case typescript
        case css
        case less
        case scss
        case json
        case json5
        case jsonStringify = "json-stringify"
        case graphql
        case markdown
        case mdx
        case vue
        case yaml
        case html
        case angular
        case lwc
    }
    
    private var context = JSContext()!
    
    public init() {
        let bundle = Bundle.module
        
        let jsFiles = [
            "standalone",
            "parser-angular",
            "parser-flow",
            "parser-babylon",
            "parser-glimmer",
            "parser-graphql",
            "parser-html",
            "parser-markdown",
            "parser-postcss",
            "parser-typescript",
        ]
        
        jsFiles.forEach {
            if let url = bundle
                .path(forResource: $0, ofType: "js") {
                let script = try? String(contentsOfFile: url)
                context.evaluateScript(script)
            }
        }
       
        // Create prettify() function
        context.evaluateScript("""
          function prettify(n, parser) {
            var config = {
              parser: parser,
              plugins: prettierPlugins
            }
            return prettier.format(n, config);
          }
      """)
    }
    
    public func prettify(_ code: String, language: Language) -> String? {
        let prettifyFunc = context.objectForKeyedSubscript("prettify")!
        
        guard let result = prettifyFunc.call(withArguments: [code, language.rawValue]).toString(), result != "undefined" else {
            return nil
        }
        
        return result
    }
}
