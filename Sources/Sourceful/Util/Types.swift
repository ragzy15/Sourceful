//
//  Types.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 24/06/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//s

#if os(macOS)
	
	import AppKit
	
	public typealias _SFView			= NSView
	public typealias SFViewController   = NSViewController
	public typealias SFWindow			= NSWindow
	public typealias SFControl		    = NSControl
	public typealias SFTextView		    = NSTextView
	public typealias SFTextField		= NSTextField
	public typealias SFButton			= NSButton
	public typealias SFFont			    = NSFont
	public typealias SFColor			= NSColor
	public typealias SFStackView		= NSStackView
	public typealias SFImage			= NSImage
	public typealias SFBezierPath		= NSBezierPath
	public typealias SFScrollView		= NSScrollView
	public typealias SFScreen			= NSScreen
	
#else
	
	import UIKit
	
	public typealias _SFView			= UIView
	public typealias SFViewController   = UIViewController
	public typealias SFWindow			= UIWindow
	public typealias SFControl		    = UIControl
	public typealias SFTextView		    = UITextView
	public typealias SFTextField		= UITextField
	public typealias SFButton			= UIButton
	public typealias SFFont			    = UIFont
	public typealias SFColor			= UIColor
	public typealias SFStackView		= UIStackView
	public typealias SFImage			= UIImage
	public typealias SFBezierPath		= UIBezierPath
	public typealias SFScrollView		= UIScrollView
	public typealias SFScreen			= UIScreen

#endif

