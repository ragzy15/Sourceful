//
//  XMLLexer.swift
//  
//
//  Created by Raghav Ahuja on 11/12/20.
//

import Foundation

public class XMLLexer: SourceCodeRegexLexer {
    
    public init() {
        
    }
    
    public func generators(source: String) -> [TokenGenerator] {
        return []
    }
}
