//
//  TestView.swift
//  Lilico
//
//  Created by Hao Fu on 6/1/22.
//

import Introspect
import SwiftUI
import SwiftUIX

struct PinStackView: View {
    var maxDigits: Int
    var emptyColor: Color
    var highlightColor: Color

//    @State
    var needClear: Bool = false {
        didSet {
            if needClear {
                $pin.wrappedValue = ""
            }
        }
    }

    @Binding
    var pin: String

    @State
    var focuse: VBaseTextFieldState = .focused

    // String is the pin code, bool is completed or not
    var handler: (String, Bool) -> Void

    func getPinColor(_ index: Int) -> Color {
        let pin = Array(self.pin)

        if pin.indices.contains(index) && !String(pin[index]).isEmpty {
            return highlightColor
        }

        return emptyColor
    }

    var body: some View {
        ZStack {
            VBaseTextField(state: $focuse,
                           text: $pin) {
                handler(pin, pin.count == maxDigits)
            }
            .onReceive(pin.publisher.collect()) {
                self.pin = String($0.prefix(maxDigits))
            }
            .keyboardType(.numberPad)
            .hidden()

//            CocoaTextField("", text: $pin) { _ in
//                handler(pin, pin.count == maxDigits)
//            } onCommit: {}
//                .isFirstResponder(focuse)
//                .introspectTextField { textField in
            ////                    delay(.milliseconds(500)) {
//                        textField.becomeFirstResponder()
            ////                    }
//                    textField.isHidden = true
//                }
//                .keyboardType(.numberPad)
//                .onReceive(pin.publisher.collect()) {
//                    self.pin = String($0.prefix(maxDigits))
//                }

            HStack(spacing: 24) {
                ForEach(0 ..< maxDigits) { digit in
//                    Text(self.getPinNumber(digit)).padding().background(Color(.systemFill))
                    Circle()
                        .frame(width: 20, height: 20, alignment: .center)
                        .foregroundColor(self.getPinColor(digit))
                }
            }
        }
        .onTapGesture {}
    }

    private func closeKeyboard() {
//        UIApplication.shared.endEditing() // Closing keyboard does not exist for swiftui yet
    }
}

struct PinStackView_Previews: PreviewProvider {
    @State
    static var test: Bool = false
    static var previews: some View {
        PinStackView(maxDigits: 6,
                     emptyColor: .gray,
                     highlightColor: Color.LL.orange,
                     needClear: false,
                     pin: .constant("")) { pin, complete in
            print(pin)
            if complete {
                test = true
            }
        }
    }
}

func delay(_ time: DispatchTimeInterval, completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + time) {
        completion()
    }
}
