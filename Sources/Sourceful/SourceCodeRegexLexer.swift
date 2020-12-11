//
//  SavannaKit+Swift.swift
//  SourceEditor
//
//  Created by Louis D'hauwe on 24/07/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

public protocol SourceCodeRegexLexer: RegexLexer {
}

extension RegexLexer {
    
    public func regexGenerator(_ identifierPattern: String, highlighterPattern: String?, options: NSRegularExpression.Options = [], transformer: @escaping TokenTransformer) -> TokenGenerator? {
        
        do {
            let regex = try NSRegularExpression(pattern: identifierPattern, options: options)
            
            if let highlighterPattern = highlighterPattern {
                let highlightRegex = try NSRegularExpression(pattern: highlighterPattern, options: options)
                
                return .regex(RegexTokenGenerator(regularExpression: regex, highligterRegularExpression: highlightRegex, tokenTransformer: transformer))
            }
            
            return .regex(RegexTokenGenerator(regularExpression: regex, tokenTransformer: transformer))
        } catch {
            return nil
        }
	}

}

extension SourceCodeRegexLexer {
	
	public func regexGenerator(_ identifierPattern: String, highlighterPattern: String? = nil, options: NSRegularExpression.Options = [], tokenType: SourceCodeTokenType) -> TokenGenerator? {
		
		return regexGenerator(identifierPattern, highlighterPattern: highlighterPattern, options: options, transformer: { (range) -> Token in
			return SimpleSourceCodeToken(type: tokenType, range: range)
		})
	}
	
	public func keywordGenerator(_ words: [String], tokenType: SourceCodeTokenType) -> TokenGenerator {
		
		return .keywords(KeywordTokenGenerator(keywords: words, tokenTransformer: { (range) -> Token in
			return SimpleSourceCodeToken(type: tokenType, range: range)
		}))
	}
	
}
