//
//  DefaultSourceCodeTheme.swift
//  SourceEditor
//
//  Created by Louis D'hauwe on 24/07/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct DefaultSourceCodeTheme: SourceCodeTheme {
	
	public init() {
		
	}
	
	private static var lineNumbersColor: SFColor {
		return SFColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
	}
	
	public let lineNumbersStyle: LineNumbersStyle? = LineNumbersStyle(font: SFFont(name: "Menlo", size: 16)!, textColor: lineNumbersColor)
	
	public let gutterStyle: GutterStyle = GutterStyle(backgroundColor: SFColor(red: 21/255.0, green: 22/255, blue: 31/255, alpha: 1.0), minimumWidth: 32)
	
    public let font: SFFont = {
        #if os(iOS)
        return SFFont.preferredFont(forTextStyle: .body)
        #endif
        
        #if os(macOS)
        if #available(macOS 11.0, *) {
           return SFFont.preferredFont(forTextStyle: .body)
        } else {
            return SFFont.systemFont(ofSize: SFFont.systemFontSize)
        }
        #endif
    }()
	
	public let backgroundColor = SFColor(red: 31/255.0, green: 32/255, blue: 41/255, alpha: 1.0)
	
	public func color(for syntaxColorType: SourceCodeTokenType) -> SFColor {
		
		switch syntaxColorType {
		case .plain:
			return .white
			
		case .number:
			return SFColor(red: 116/255, green: 109/255, blue: 176/255, alpha: 1.0)
			
		case .string:
			return SFColor(red: 211/255, green: 35/255, blue: 46/255, alpha: 1.0)
			
		case .identifier:
			return SFColor(red: 20/255, green: 156/255, blue: 146/255, alpha: 1.0)
            
        case .attribute:
            return SFColor.yellow
            
        case .docType:
            return SFColor.gray
			
		case .keyword:
			return SFColor(red: 215/255, green: 0, blue: 143/255, alpha: 1.0)
			
		case .comment:
			return SFColor(red: 69.0/255.0, green: 187.0/255.0, blue: 62.0/255.0, alpha: 1.0)
			
		case .editorPlaceholder:
			return backgroundColor
		}
	}
}
