//
//  HTMLLexer.swift
//  
//
//  Created by Raghav Ahuja on 11/12/20.
//

import Foundation

public class HTMLLexer: SourceCodeRegexLexer {
    
    public static let shared = HTMLLexer()
    
    private let jsLexer = JavaScriptLexer()
    
    lazy var generators: [TokenGenerator] = {
        
        var generators = [TokenGenerator?]()
        
        // DocType
        generators.append(regexGenerator("<![doctype|DOCTYPE](.*)>", tokenType: .docType))
        
        // Tag
        generators.append(regexGenerator("<[?]*(?=[^!])([^!\"]\"[^\"]*\"|'[^']*'|[^'\">])*>", tokenType: .identifier))
        
        // Attribute
//        generators.append(regexGenerator("[ ][\\w-]+(?=[^<]*>)", tokenType: .attribute))
        generators.append(regexGenerator("[ ][\\w-]+[\\s]*[=](?=[^<]*>)", highlighterPattern: "[ ][\\w-]+", tokenType: .attribute))
        
        // Number
        generators.append(regexGenerator("(?<=(\\s|\\[|,|:))(\\d|\\.|_)+", tokenType: .number))
        
        // Single-line string literal
        generators.append(regexGenerator("(=\\s?\"|@\")[^\"\\n]*(@\"|\")", highlighterPattern: "(\"|@\")[^\"\\n]*(@\"|\")", tokenType: .string))
        
        // Comment
        generators.append(regexGenerator("<!--[\\s\\S]*-->", options: .caseInsensitive, tokenType: .comment))
        
        // Editor placeholder
        var editorPlaceholderPattern = "(<#)[^\"\\n]*"
        editorPlaceholderPattern += "(#>)"
        generators.append(regexGenerator(editorPlaceholderPattern, tokenType: .editorPlaceholder))
        
        return generators.compactMap { $0 }
    }()
    
    public init() {
        
    }
    
    public func generators(source: String) -> [TokenGenerator] {
        return generators + jsLexer.generators
    }
}
