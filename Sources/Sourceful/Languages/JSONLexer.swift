//
//  JSONLexer.swift
//  
//
//  Created by Raghav Ahuja on 09/12/20.
//

import Foundation

public class JSONLexer: SourceCodeRegexLexer {
    
    public init() {
        
    }
    
    lazy var generators: [TokenGenerator] = {
        
        var generators = [TokenGenerator?]()
        
        generators.append(regexGenerator(":\\s?(?<=(\\s|\\[|,|:))(\\d|\\.|_)+", highlighterPattern: "(?<=(\\s|\\[|,|:))(\\d|\\.|_)+", tokenType: .number))
        
        generators.append(regexGenerator("\\.[A-Za-z_]+\\w*", tokenType: .identifier))
        
        // Line comment
        generators.append(regexGenerator("//(.*)", tokenType: .comment))
        
        // Block comment
        generators.append(regexGenerator("(/\\*)(.*)(\\*/)", options: [.dotMatchesLineSeparators], tokenType: .comment))
        
        // JSON Key
        generators.append(regexGenerator("(\"|@\")[^\"\\n]*(@\"|\"\\s?:)", highlighterPattern: "(\"|@\")[^\"\\n]*(@\"|\")", tokenType: .keyword))
        
        // Single-line string literal or JSON Value
        generators.append(regexGenerator("(:\\s?\"|@\")[^\"\\n]*(@\"|\")", highlighterPattern: "(\"|@\")[^\"\\n]*(@\"|\")", tokenType: .string))
        
        // Editor placeholder
        var editorPlaceholderPattern = "(<#)[^\"\\n]*"
        editorPlaceholderPattern += "(#>)"
        generators.append(regexGenerator(editorPlaceholderPattern, tokenType: .editorPlaceholder))
        
        return generators.compactMap( { $0 })
    }()
    
    public func generators(source: String) -> [TokenGenerator] {
        return generators
    }
}
