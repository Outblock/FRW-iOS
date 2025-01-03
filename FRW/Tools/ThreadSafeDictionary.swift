//
//  ThreadSafeDictionary.swift
//
//  Created by Shashank on 29/10/20.
//

import Foundation

class ThreadSafeDictionary<V: Hashable, T>: Collection {
    // MARK: Lifecycle

    init(dict: [V: T] = [V: T]()) {
        self.dictionary = dict
    }

    // MARK: Internal

    var keys: Dictionary<V, T>.Keys {
        concurrentQueue.sync {
            self.dictionary.keys
        }
    }

    var values: Dictionary<V, T>.Values {
        concurrentQueue.sync {
            self.dictionary.values
        }
    }

    var startIndex: Dictionary<V, T>.Index {
        concurrentQueue.sync {
            self.dictionary.startIndex
        }
    }

    var endIndex: Dictionary<V, T>.Index {
        concurrentQueue.sync {
            self.dictionary.endIndex
        }
    }

    // this is because it is an apple protocol method
    // swiftlint:disable identifier_name
    func index(after i: Dictionary<V, T>.Index) -> Dictionary<V, T>.Index {
        concurrentQueue.sync {
            self.dictionary.index(after: i)
        }
    }

    // swiftlint:enable identifier_name

    subscript(key: V) -> T? {
        set(newValue) {
            concurrentQueue.async(flags: .barrier) { [weak self] in
                self?.dictionary[key] = newValue
            }
        }
        get {
            concurrentQueue.sync {
                self.dictionary[key]
            }
        }
    }

    // has implicity get
    subscript(index: Dictionary<V, T>.Index) -> Dictionary<V, T>.Element {
        concurrentQueue.sync {
            self.dictionary[index]
        }
    }

    func removeValue(forKey key: V) {
        concurrentQueue.async(flags: .barrier) { [weak self] in
            self?.dictionary.removeValue(forKey: key)
        }
    }

    func removeAll() {
        concurrentQueue.async(flags: .barrier) { [weak self] in
            self?.dictionary.removeAll()
        }
    }

    // MARK: Private

    private var dictionary: [V: T]
    private let concurrentQueue = DispatchQueue(
        label: "Dictionary Barrier Queue",
        attributes: .concurrent
    )
}
