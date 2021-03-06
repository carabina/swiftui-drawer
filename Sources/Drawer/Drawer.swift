//
//  Drawer.swift
//
//
//  Created by Michael Verges on 7/14/20.
//

import SwiftUI

/// A bottom-up view that conforms to multiple heights
public struct Drawer<Content>: View where Content: View {
    
    // MARK: Public Variables
    
    /// The possible resting heights of the drawer
    @Binding public var heights: [CGFloat]
    
    /// The current height of the displayed drawer
    @State public var height: CGFloat
    
    /// The current height marker the drawer is conformed to. Change triggers `onRest`
    @State internal var restingHeight: CGFloat {
        didSet {
            didRest?(restingHeight)
        }
    }
    
    /// A callback executed when the drawer reaches a restingHeight
    internal var didRest: ((_ height: CGFloat) -> ())? = nil
    
    @Binding internal var locked: Bool
    
    internal var lockedHeight: (_ restingHeight: CGFloat) -> CGFloat
    
    // MARK: Orientation
    
    public struct SizeClass: Equatable {
        var horizontal: UserInterfaceSizeClass?
        var vertical: UserInterfaceSizeClass?
    }
    
    @Environment(\.verticalSizeClass) internal var verticalSizeClass
    @Environment(\.horizontalSizeClass) internal var horizontalSizeClass
    @State internal var sizeClass: SizeClass = SizeClass(
        horizontal: nil,
        vertical: nil) {
        didSet { didLayoutForSizeClass?(sizeClass) }
    }
    
    /// A callback executed when the drawer is layed out for a new size class
    internal var didLayoutForSizeClass: ((SizeClass) -> ())? = nil
    
    // MARK: Width
    
    @Binding internal var alignment: DrawerAlignment
    
    @Binding internal var fixedWidth: CGFloat?
    
    // MARK: Gestures
    
    @State internal var dragging: Bool = false
    
    // MARK: Animation
    
    /// Additional height to spring past the last height marker
    internal var springHeight: CGFloat = 12
    
    @State internal var animation: Animation? = Animation.spring()
    
    // MARK: Haptics
    
    internal var impactGenerator: UIImpactFeedbackGenerator?
    
    // MARK: View
    
    internal var content: Content
}

// MARK: Public init

public extension Drawer {
    
    /// A bottom-up view that conforms to multiple heights
    /// - Parameters:
    ///   - heights: The possible resting heights of the drawer
    ///   - startingHeight: The starting height of the drawer. Defaults to the first height marker if not specified
    ///   - content: The view that defines the drawer
    init(
        heights: Binding<[CGFloat]> = .constant([0]),
        startingHeight: CGFloat? = nil,
        @ViewBuilder _ content: () -> Content
    ) {
        self._heights = heights
        self._height = .init(initialValue: startingHeight ?? heights.wrappedValue.first!)
        self._restingHeight = .init(initialValue: startingHeight ?? heights.wrappedValue.first!)
        self.content = content()
        self._locked = .constant(false)
        self.lockedHeight = { _ in return CGFloat.zero }
        self._alignment = .constant(.fullscreen)
        self._fixedWidth = .constant(nil)
    }
    
    /// A bottom-up view that conforms to multiple heights
    /// - Parameters:
    ///   - heights: The possible resting heights of the drawer
    ///   - startingHeight: The starting height of the drawer. Defaults to the first height marker if not specified
    ///   - content: The view that defines the drawer
    @available(*, deprecated)
    init(
        heights: [CGFloat],
        startingHeight: CGFloat? = nil,
        @ViewBuilder _ content: () -> Content
    ) {
        self._heights = .constant(heights)
        self._height = .init(initialValue: startingHeight ?? heights.first!)
        self._restingHeight = .init(initialValue: startingHeight ?? heights.first!)
        self.content = content()
        self._locked = .constant(false)
        self.lockedHeight = { _ in return CGFloat.zero }
        self._alignment = .constant(.fullscreen)
        self._fixedWidth = .constant(nil)
    }
    
    // MARK: Deprecated Inits
    
    /// A bottom-up view that conforms to multiple heights
    /// - Parameters:
    ///   - heights: The possible resting heights of the drawer
    ///   - startingHeight: The starting height of the drawer. Defaults to the first height marker if not specified
    ///   - content: The view that defines the drawer
    @available(*, deprecated)
    init(
        heights: [CGFloat],
        startingHeight: CGFloat? = nil,
        impact: UIImpactFeedbackGenerator.FeedbackStyle?,
        @ViewBuilder _ content: () -> Content
    ) {
        self._heights = .constant(heights)
        self._height = .init(initialValue: startingHeight ?? heights.first!)
        self._restingHeight = .init(initialValue: startingHeight ?? heights.first!)
        self.content = content()
        if let impact = impact {
            self.impactGenerator = UIImpactFeedbackGenerator(style: impact)
        }
        self._locked = .constant(false)
        self.lockedHeight = { _ in return CGFloat.zero }
        self._alignment = .constant(.fullscreen)
        self._fixedWidth = .constant(nil)
    }
}

internal extension Drawer {
    init(
        heights: Binding<[CGFloat]>,
        height: CGFloat,
        restingHeight: CGFloat,
        springHeight: CGFloat,
        didRest: ((_ height: CGFloat) -> ())?,
        didLayoutForSizeClass: ((SizeClass) -> ())?,
        alignment: Binding<DrawerAlignment>,
        width: Binding<CGFloat?>,
        impactGenerator: UIImpactFeedbackGenerator?,
        locked: Binding<Bool>,
        lockedHeight: @escaping (CGFloat) -> CGFloat,
        content: Content
    ) {
        self._heights = heights
        self._height = .init(initialValue: height)
        self._restingHeight = .init(initialValue: restingHeight)
        self.springHeight = springHeight
        self.didRest = didRest
        self.didLayoutForSizeClass = didLayoutForSizeClass
        self._fixedWidth = width
        self._alignment = alignment
        self.content = content
        self.impactGenerator = impactGenerator
        self.lockedHeight = lockedHeight
        self._locked = locked
        
    }
}

public enum DrawerAlignment {
    case leading, center, trailing, fullscreen
}
