import Combine
import Foundation
import SwiftUI

// MARK: - ViewModel

protocol ViewModel: ObservableObject where ObjectWillChangePublisher.Output == Void {
    associatedtype State
    associatedtype Input

    var state: State { get }
    func trigger(_ input: Input)
    func toAnyViewModel() -> AnyViewModel<State, Input>
}

extension ViewModel {
    func toAnyViewModel() -> AnyViewModel<State, Input> {
        AnyViewModel(self)
    }
}

// MARK: - AnyViewModel + Identifiable

extension AnyViewModel: Identifiable where State: Identifiable {
    var id: State.ID {
        state.id
    }
}

// MARK: - AnyViewModel

@dynamicMemberLookup
final class AnyViewModel<State, Input>: ViewModel {
    // MARK: Lifecycle

    // MARK: Initialization

    init<V: ViewModel>(_ viewModel: V) where V.State == State, V.Input == Input {
        self.wrappedObjectWillChange = { viewModel.objectWillChange.eraseToAnyPublisher() }
        self.wrappedState = { viewModel.state }
        self.wrappedTrigger = viewModel.trigger
    }

    // MARK: Internal

    // MARK: Computed properties

    var objectWillChange: AnyPublisher<Void, Never> {
        wrappedObjectWillChange()
    }

    var state: State {
        wrappedState()
    }

    // MARK: Methods

    func trigger(_ input: Input) {
        wrappedTrigger(input)
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<State, Value>) -> Value {
        state[keyPath: keyPath]
    }

    // MARK: Private

    // MARK: Stored properties

    private let wrappedObjectWillChange: () -> AnyPublisher<Void, Never>
    private let wrappedState: () -> State
    private let wrappedTrigger: (Input) -> Void
}
