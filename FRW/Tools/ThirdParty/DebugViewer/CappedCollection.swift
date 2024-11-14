//
//  CappedCollection.swift
//
//
//  Created by Jin Kim on 6/13/22.
//

import Foundation

// MARK: - CappedCollection

struct CappedCollection<T> {
    // MARK: Lifecycle

    init(
        elements: [T], maxCount: Int
    ) {
        self.elements = elements
        self.maxCount = maxCount
    }

    // MARK: Internal

    var maxCount: Int

    // MARK: Private

    private var elements: [T]
}

// MARK: Collection, ExpressibleByArrayLiteral

extension CappedCollection: Collection, ExpressibleByArrayLiteral {
    typealias Index = Int
    typealias Element = T

    init(
        arrayLiteral elements: Element...
    ) {
        self.elements = elements
        self.maxCount = elements.count
    }

    var startIndex: Index { elements.startIndex }
    var endIndex: Index { elements.endIndex }

    subscript(index: Index) -> Element { elements[index] }

    func index(after i: Index) -> Index {
        elements.index(after: i)
    }

    @discardableResult
    mutating func append(_ newElement: Element) -> Element? {
        insert(newElement, at: 0)
        return removeExtraElements().first
    }

    @discardableResult
    mutating func append<C>(contentsOf newElements: C) -> [Element] where C: Collection,
        CappedCollection.Element == C.Element {
        insert(contentsOf: newElements, at: 0)
        return removeExtraElements()
    }

    @discardableResult
    mutating func insert(_ newElement: Element, at i: Int) -> Element? {
        elements.insert(newElement, at: i)
        return removeExtraElements().first
    }

    @discardableResult
    mutating func insert<C>(contentsOf newElements: C, at i: Int) -> [Element] where C: Collection,
        CappedCollection.Element == C.Element {
        elements.insert(contentsOf: newElements, at: i)
        return removeExtraElements()
    }

    private mutating func removeExtraElements() -> [Element] {
        guard elements.count > maxCount else { return [] }

        var poppedElements: [Element] = []
        poppedElements.append(contentsOf: elements[maxCount..<elements.count])
        elements.removeLast(elements.count - maxCount)
        return poppedElements
    }

    mutating func removeAllElements() {
        elements.removeAll()
    }
}
