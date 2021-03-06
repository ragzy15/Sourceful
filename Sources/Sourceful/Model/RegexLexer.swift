//
//  RegexLexer.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 05/07/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

public typealias TokenTransformer = (_ range: Range<String.Index>) -> Token

public struct RegexTokenGenerator {
    
    public let regularExpression: NSRegularExpression
    
    public let highligterRegularExpression: NSRegularExpression?
	
	public let tokenTransformer: TokenTransformer
	
	public init(regularExpression: NSRegularExpression, highligterRegularExpression: NSRegularExpression? = nil, tokenTransformer: @escaping TokenTransformer) {
		self.regularExpression = regularExpression
        self.highligterRegularExpression = highligterRegularExpression
		self.tokenTransformer = tokenTransformer
	}
}

public struct KeywordTokenGenerator {
	
	public let keywords: [String]
	
	public let tokenTransformer: TokenTransformer
	
	public init(keywords: [String], tokenTransformer: @escaping TokenTransformer) {
		self.keywords = keywords
		self.tokenTransformer = tokenTransformer
	}
	
}

public enum TokenGenerator {
	case keywords(KeywordTokenGenerator)
	case regex(RegexTokenGenerator)
}

public protocol RegexLexer: Lexer {
	
	func generators(source: String) -> [TokenGenerator]
	
}

extension RegexLexer {
	
	public func getSavannaTokens(input: String) -> [Token] {
		
		let generators = self.generators(source: input)
		
		var tokens = [Token]()
		
		for generator in generators {
			
			switch generator {
			case .regex(let regexGenerator):
                let sourceRange = NSRange(location: 0, length: input.utf16.count)
                tokens.append(contentsOf: generateRegexTokens(regexGenerator, source: input, sourceRange: sourceRange))

			case .keywords(let keywordGenerator):
				tokens.append(contentsOf: generateKeywordTokens(keywordGenerator, source: input))
			}
		}
	
		return tokens
	}
}

extension RegexLexer {

    func generateKeywordTokens(_ generator: KeywordTokenGenerator, source: String) -> [Token] {

		var tokens = [Token]()

		source.enumerateSubstrings(in: source.startIndex ..< source.endIndex, options: [.byWords]) { (word, range, _, _) in
			if let word = word, generator.keywords.contains(word) {
				let token = generator.tokenTransformer(range)
				tokens.append(token)
			}
		}

		return tokens
	}
	
	public func generateRegexTokens(_ generator: RegexTokenGenerator, source: String, sourceRange: NSRange) -> [Token] {

		var tokens = [Token]()

        let matches = generator.regularExpression.matches(in: source, options: [], range: sourceRange)
        
        for numberMatch in matches {
			
			guard let swiftRange = Range(numberMatch.range, in: source) else {
				continue
			}
            
            if let regularExpression = generator.highligterRegularExpression {
                if let highlightNSRange = regularExpression.firstMatch(in: source, options: [], range: numberMatch.range) {
                    
                    guard let swiftHiglightRange = Range(highlightNSRange.range, in: source) else {
                        continue
                    }
                    
                    let token = generator.tokenTransformer(swiftHiglightRange)
                    tokens.append(token)
                } else {
                    continue
                }
            } else {
                let token = generator.tokenTransformer(swiftRange)
                tokens.append(token)
            }
		}
		
		return tokens
	}
}
