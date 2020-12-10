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
    
    public struct Customization {
        var didChangeText: (SourceCodeTextEditor) -> Void
        var insertionPointColor: () -> SFColor
        var lexerForSource: (String) -> Lexer
        var textViewDidBeginEditing: (SourceCodeTextEditor) -> Void
        var theme: () -> SourceCodeTheme
        
        /// Creates a **Customization** to pass into the *init()* of a **SourceCodeTextEditor**.
        ///
        /// - Parameters:
        ///     - didChangeText: A SyntaxTextView delegate action.
        ///     - lexerForSource: The lexer to use (default: SwiftLexer()).
        ///     - insertionPointColor: To customize color of insertion point caret (default: .white).
        ///     - textViewDidBeginEditing: A SyntaxTextView delegate action.
        ///     - theme: Custom theme (default: DefaultSourceCodeTheme()).
        public init(
            didChangeText: @escaping (SourceCodeTextEditor) -> Void,
            insertionPointColor: @escaping () -> SFColor,
            lexerForSource: @escaping (String) -> Lexer,
            textViewDidBeginEditing: @escaping (SourceCodeTextEditor) -> Void,
            theme: @escaping () -> SourceCodeTheme
        ) {
            self.didChangeText = didChangeText
            self.insertionPointColor = insertionPointColor
            self.lexerForSource = lexerForSource
            self.textViewDidBeginEditing = textViewDidBeginEditing
            self.theme = theme
        }
    }
    
    @Binding private var text: String
    
    private var customization: Customization
    
    public init(
        text: Binding<String>,
        customization: Customization = Customization(
            didChangeText: { _ in },
            insertionPointColor: { SFColor.white },
            lexerForSource: { _ in JSONLexer() },
            textViewDidBeginEditing: { _ in },
            theme: { DefaultSourceCodeTheme() }
        )
    ) {
        self._text = text
        self.customization = customization
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    #if os(iOS)
    public func makeUIView(context: Context) -> SyntaxTextView {
        let wrappedView = SyntaxTextView()
        wrappedView.delegate = context.coordinator
        wrappedView.theme = customization.theme()
//        wrappedView.contentTextView.insertionPointColor = custom.insertionPointColor()
        
        context.coordinator.wrappedView = wrappedView
        context.coordinator.wrappedView.text = text
        
        return wrappedView
    }
    
    public func updateUIView(_ view: SyntaxTextView, context: Context) {
    }
    #endif
    
    #if os(macOS)
    public func makeNSView(context: Context) -> SyntaxTextView {
        let wrappedView = SyntaxTextView()
        wrappedView.delegate = context.coordinator
        wrappedView.theme = customization.theme()
        wrappedView.contentTextView.insertionPointColor = customization.insertionPointColor()
        
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
        
        private var textUpdateNotificationObserver: AnyCancellable?
        
        init(_ parent: SourceCodeTextEditor) {
            self.parent = parent
            
            textUpdateNotificationObserver = NotificationCenter.default.publisher(for: SourceCodeTextEditor.textUpdateNotification)
                .compactMap { $0.userInfo?["text"] as? String }
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { (newText) in
                    self.wrappedView.text = newText
                })
        }
        
        deinit {
            textUpdateNotificationObserver?.cancel()
        }
        
        public func lexerForSource(_ source: String) -> Lexer {
            parent.customization.lexerForSource(source)
        }
        
        public func didChangeText(_ syntaxTextView: SyntaxTextView) {
            DispatchQueue.main.async {
                self.parent.text = syntaxTextView.text
            }
            
            // allow the client to decide on thread
            parent.customization.didChangeText(parent)
        }
        
        public func textViewDidBeginEditing(_ syntaxTextView: SyntaxTextView) {
            parent.customization.textViewDidBeginEditing(parent)
        }
    }
}

#endif
#endif
