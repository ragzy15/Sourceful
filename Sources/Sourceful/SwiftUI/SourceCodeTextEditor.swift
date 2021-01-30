//
//  SourceCodeTextEditor.swift
//
//  Created by Andrew Eades on 14/08/2020.
//

import Foundation

#if canImport(Combine)

import Combine

#if canImport(SwiftUI)

import SwiftUI

#if os(macOS)
@available(macOS 10.15, *)
public typealias _ViewRepresentable = NSViewRepresentable

#endif

#if os(iOS)

@available(iOS 13.0, *)
public typealias _ViewRepresentable = UIViewRepresentable

#endif


@available(iOS 13.0, macOS 10.15, *)
public struct SourceCodeTextEditor: _ViewRepresentable {
    
    public static let textUpdateNotification = Notification.Name("SourceCodeTextEditor_stextUpdateNotification")
    
    public struct SourceCodeCustomization {
        var didChangeText: (SourceCodeTextEditor) -> Void
        var insertionPointColor: () -> SFColor
        var lexerForSource: (String) -> Lexer
        var textViewDidBeginEditing: (SourceCodeTextEditor) -> Void
        var theme: () -> SourceCodeTheme
        
        /// Creates a **SourceCodeCustomization** to pass into the *init()* of a **SourceCodeTextEditor**.
        ///
        /// - Parameters:
        ///     - didChangeText: A SyntaxTextView delegate action.
        ///     - lexerForSource: The lexer to use (default: SwiftLexer()).
        ///     - insertionPointColor: To customize color of insertion point caret (default: .white).
        ///     - textViewDidBeginEditing: A SyntaxTextView delegate action.
        ///     - theme: Custom theme (default: DefaultSourceCodeTheme()).
        public init(
            didChangeText: @escaping (SourceCodeTextEditor) -> Void = { _ in },
            insertionPointColor: @escaping () -> SFColor = { .white },
            lexerForSource: @escaping (String) -> Lexer,
            textViewDidBeginEditing: @escaping (SourceCodeTextEditor) -> Void = { _ in },
            theme: @escaping () -> SourceCodeTheme = { DefaultSourceCodeTheme() }
        ) {
            self.didChangeText = didChangeText
            self.insertionPointColor = insertionPointColor
            self.lexerForSource = lexerForSource
            self.textViewDidBeginEditing = textViewDidBeginEditing
            self.theme = theme
        }
    }
    
    public struct EditorCusomtization {
        public let isEditable: Bool
        public let notificationObject: AnyObject?
        #if os(iOS)
        public let isScrollEnabled: Bool
        public let contentInset: UIEdgeInsets
        public let allowsEditingTextAttributes: Bool
        
        public init(isEditable: Bool = true, isScrollEnabled: Bool = true,
                    allowsEditingTextAttributes: Bool = false,
                    notificationObject: AnyObject?,
                    contentInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)) {
            
            self.isEditable = isEditable
            self.isScrollEnabled = isScrollEnabled
            self.allowsEditingTextAttributes = allowsEditingTextAttributes
            self.notificationObject = notificationObject
            self.contentInset = contentInset
        }
        #endif
        
        #if os(macOS)
        public init(isEditable: Bool = true, notificationObject: AnyObject?) {
            self.isEditable = isEditable
            self.notificationObject = notificationObject
        }
        #endif
    }
    
    @Binding private var text: String
    @Binding private var fixedHeight: CGFloat
    
    private let width: CGFloat?
    private let sourceCodeCustomization: SourceCodeCustomization
    private let editorCustomization: EditorCusomtization
    
    public init(text: Binding<String>, fixedHeight: Binding<CGFloat> = .constant(0), width: CGFloat? = nil, customization: SourceCodeCustomization, editorCustomization: EditorCusomtization = EditorCusomtization(notificationObject: nil)) {
        self._text = text
        self._fixedHeight = fixedHeight
        self.width = width
        self.sourceCodeCustomization = customization
        self.editorCustomization = editorCustomization
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    #if os(iOS)
    public func makeUIView(context: Context) -> SyntaxTextView {
        let wrappedView = SyntaxTextView()
        wrappedView.delegate = context.coordinator
        wrappedView.theme = sourceCodeCustomization.theme()
        wrappedView.textView.isEditable = editorCustomization.isEditable
        wrappedView.textView.allowsEditingTextAttributes = editorCustomization.allowsEditingTextAttributes
        wrappedView.textView.contentInset = editorCustomization.contentInset
        wrappedView.textView.isScrollEnabled = editorCustomization.isScrollEnabled
        wrappedView.textView.adjustsFontForContentSizeCategory = true
        wrappedView.textView.sizeToFit()
//        wrappedView.contentTextView.insertionPointColor = custom.insertionPointColor()
        
        context.coordinator.wrappedView = wrappedView
        context.coordinator.wrappedView.text = text
        return wrappedView
    }
    
    public func updateUIView(_ view: SyntaxTextView, context: Context) {
//        context.coordinator.wrappedView.text = text
    }
    #endif
    
    #if os(macOS)
    public func makeNSView(context: Context) -> SyntaxTextView {
        let wrappedView = SyntaxTextView()
        wrappedView.delegate = context.coordinator
        wrappedView.theme = sourceCodeCustomization.theme()
        wrappedView.textView.isEditable = editorCustomization.isEditable
        
        wrappedView.contentTextView.insertionPointColor = sourceCodeCustomization.insertionPointColor()
        
        context.coordinator.wrappedView = wrappedView
        context.coordinator.wrappedView.text = text
        
        return wrappedView
    }
    
    public func updateNSView(_ view: SyntaxTextView, context: Context) {
    }
    #endif
}

@available(iOS 13.0, macOS 10.15, *)
extension SourceCodeTextEditor {
    
    public class Coordinator: SyntaxTextViewDelegate {
        let parent: SourceCodeTextEditor
        var wrappedView: SyntaxTextView!
        
        private var cancellableBag = Set<AnyCancellable>()
        
        init(_ parent: SourceCodeTextEditor) {
            self.parent = parent
            
            NotificationCenter.default.publisher(for: SourceCodeTextEditor.textUpdateNotification, object: parent.editorCustomization.notificationObject)
                .compactMap { $0.userInfo?["text"] as? String }
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] (newText) in
                    self?.wrappedView.text = newText
                })
                .store(in: &cancellableBag)
            
            #if os(iOS)
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { $0.userInfo }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (userInfo) in
                    if let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                        self?.wrappedView.textView.contentInset.bottom += frame.height
                    }
                }
                .store(in: &cancellableBag)
            
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                .compactMap { $0.userInfo }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (userInfo) in
                    if let frame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                        self?.wrappedView.textView.contentInset.bottom -= frame.height
                    }
                }
                .store(in: &cancellableBag)
            #endif
        }
        
        public func lexerForSource(_ source: String) -> Lexer {
            parent.sourceCodeCustomization.lexerForSource(source)
        }
        
        public func didChangeText(_ syntaxTextView: SyntaxTextView) {
            DispatchQueue.main.async {
                self.parent.text = syntaxTextView.text
                if let width = self.parent.width {
                    #if os(iOS)
                    let insetWidth = syntaxTextView.textView.textContainerInset.left + syntaxTextView.textView.textContainerInset.right
                    let size = syntaxTextView.textView.sizeThatFits(CGSize(width: width - insetWidth, height: .infinity))
                    #else
                    syntaxTextView.textView.sizeToFit()
                    let size = syntaxTextView.textView.fittingSize
                    #endif
                    self.parent.fixedHeight = size.height
                }
            }
            
            // allow the client to decide on thread
            parent.sourceCodeCustomization.didChangeText(parent)
        }
        
        public func textViewDidBeginEditing(_ syntaxTextView: SyntaxTextView) {
            parent.sourceCodeCustomization.textViewDidBeginEditing(parent)
        }
    }
}

#endif
#endif
