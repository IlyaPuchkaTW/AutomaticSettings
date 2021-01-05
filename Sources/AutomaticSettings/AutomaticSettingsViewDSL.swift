import Combine
import SwiftUI

///
/// @_disfavoredOverload is used to hint the compiler which overload to use if multiple generic matchers would apply
/// the order in which functions appear matters so don't change it unless you want to change behaviour
///

/// View that provides DSL functions related to `AutomaticSettingsViewModel` and your View implementation
public protocol AutomaticSettingsViewDSL {
    associatedtype ExternalData: ObservableObject
    associatedtype Settings: Equatable
    var viewModel: AutomaticSettingsViewModel<Settings, ExternalData> { get }
}

public extension AutomaticSettingsViewDSL {
    func navigationLink<Content>(_ label: String, @ViewBuilder content: () -> Content) -> some View where Content: View {
        NavigationLink(
            label,
            destination:
            Form {
                content()
            }
            .navigationBarTitle(label)
        )
    }

    // MARK: - Enums & Displayable

    func setting<Type>(_ name: String, keyPath: WritableKeyPath<Settings, Type>, requiresRestart: Bool = false, sideEffect: (() -> Void)? = nil, uniqueIdentifier: String) -> some View where Type: SettingsDisplayable {
        setting(
            name,
            keyPath: keyPath,
            display: { $0.settingsTitle },
            allVariants: Type.settingsVariants,
            requiresRestart: requiresRestart,
            sideEffect: sideEffect,
            uniqueIdentifier: uniqueIdentifier
        )
    }

    @_disfavoredOverload
    func setting<Type>(_ name: String, keyPath: WritableKeyPath<Settings, Type>, requiresRestart: Bool = false, sideEffect: (() -> Void)? = nil, uniqueIdentifier: String) -> some View where Type: CaseIterable, Type: Hashable, Type: RawRepresentable, Type.RawValue == String {
        setting(
            name,
            keyPath: keyPath,
            display: { $0.rawValue.settings_uppercasedFirst },
            allVariants: Array(Type.allCases),
            requiresRestart: requiresRestart,
            sideEffect: sideEffect,
            uniqueIdentifier: uniqueIdentifier
        )
    }

    func setting<Type>(_ name: String, keyPath: WritableKeyPath<Settings, Type>, display: @escaping (Type) -> String, allVariants: [Type], requiresRestart: Bool = false, sideEffect: (() -> Void)? = nil, uniqueIdentifier: String) -> some View where Type: Hashable {
        Picker(
            selection: viewModel.binding(
                keyPath: keyPath,
                requiresRestart: requiresRestart,
                uniqueIdentifier: uniqueIdentifier,
                sideEffect: sideEffect
            ),
            label: Text(name.settings_titleCase).font(.body),
            content: {
                ForEach(allVariants, id: \.self) { variant in
                    Text(display(variant))
                        .font(.footnote)
                        .tag(variant)
                }
            }
        )
    }

    // MARK: - Primitive Values

    @_disfavoredOverload
    func setting(_ name: String, keyPath: WritableKeyPath<Settings, Bool>, requiresRestart: Bool = false, sideEffect: (() -> Void)? = nil, uniqueIdentifier: String) -> some View {
        Toggle(
            name.settings_titleCase,
            isOn: viewModel.binding(
                keyPath: keyPath,
                requiresRestart: requiresRestart,
                uniqueIdentifier: uniqueIdentifier,
                sideEffect: sideEffect
            )
        )
    }

    @_disfavoredOverload
    func setting<Number>(_ name: String, keyPath: WritableKeyPath<Settings, Number>, requiresRestart: Bool = false, sideEffect: (() -> Void)? = nil, uniqueIdentifier: String, range: ClosedRange<Number>) -> some View where Number: BinaryFloatingPoint, Number.Stride: BinaryFloatingPoint, Number: _FormatSpecifiable {
        VStack {
            HStack {
                Slider(
                    value: viewModel.binding(
                        keyPath: keyPath,
                        requiresRestart: requiresRestart,
                        uniqueIdentifier: uniqueIdentifier,
                        sideEffect: sideEffect
                    ),
                    in: range
                )
            }
            Text("\(name.settings_titleCase): \(viewModel.current[keyPath: keyPath])")
        }
    }

    @_disfavoredOverload
    func setting<Number>(_ name: String, keyPath: WritableKeyPath<Settings, Number>, requiresRestart: Bool = false, sideEffect: (() -> Void)? = nil, uniqueIdentifier: String) -> some View where Number: BinaryFloatingPoint, Number.Stride: BinaryFloatingPoint, Number: _FormatSpecifiable {
        VStack {
            HStack {
                Slider(
                    value: viewModel.binding(
                        keyPath: keyPath,
                        requiresRestart: requiresRestart,
                        uniqueIdentifier: uniqueIdentifier,
                        sideEffect: sideEffect
                    )
                )
            }
            Text("\(name.settings_titleCase): \(viewModel.current[keyPath: keyPath])")
        }
    }

    @_disfavoredOverload
    func setting<Number>(_ name: String, keyPath: WritableKeyPath<Settings, Number>, requiresRestart: Bool = false, sideEffect: (() -> Void)? = nil, uniqueIdentifier: String) -> some View where Number: Strideable, Number: _FormatSpecifiable {
        Stepper(value: viewModel.binding(
            keyPath: keyPath,
            requiresRestart: requiresRestart,
            uniqueIdentifier: uniqueIdentifier,
            sideEffect: sideEffect
        )
        ) {
            Text("\(name.settings_titleCase): \(viewModel.current[keyPath: keyPath])")
        }
    }

    @_disfavoredOverload
    func setting(_ name: String, keyPath: WritableKeyPath<Settings, String>, requiresRestart: Bool = false, sideEffect: (() -> Void)? = nil, uniqueIdentifier: String) -> some View {
        HStack {
            Text(name.settings_titleCase)
                .fixedSize()
            Spacer()
            TextField(
                name.settings_titleCase,
                text: viewModel.binding(
                    keyPath: keyPath,
                    requiresRestart: requiresRestart,
                    uniqueIdentifier: uniqueIdentifier,
                    sideEffect: sideEffect
                )
            )
            .fixedSize()
        }
    }

    @_disfavoredOverload
    func setting(_ name: String, keyPath: WritableKeyPath<Settings, String?>, requiresRestart: Bool = false, sideEffect: (() -> Void)? = nil, uniqueIdentifier: String) -> some View {
        HStack {
            Text(name.settings_titleCase)
                .fixedSize()
            Spacer()
            TextField(
                name.settings_titleCase,
                text: Binding(get: {
                    return self.viewModel.current[keyPath: keyPath] ?? ""
                }, set: {
                    self.viewModel.change(
                        keyPath: keyPath,
                        requiresRestart: requiresRestart,
                        uniqueIdentifier: uniqueIdentifier,
                        to: $0,
                        sideEffect: sideEffect
                    )
                })
            )
            .fixedSize()
        }
    }

    @_disfavoredOverload
    func setting<Number>(_ name: String, keyPath: WritableKeyPath<Settings, Number?>, requiresRestart: Bool = false, sideEffect: (() -> Void)? = nil, uniqueIdentifier: String) -> some View where Number: StringConvertibleNumber {
        HStack {
            Text(name.settings_titleCase)
                .fixedSize()
            Spacer()
            TextField(
                name.settings_titleCase,
                text: Binding(get: {
                    return self.viewModel.current[keyPath: keyPath].map { "\($0)" } ?? ""
                }, set: {
                    self.viewModel.change(
                        keyPath: keyPath,
                        requiresRestart: requiresRestart,
                        uniqueIdentifier: uniqueIdentifier,
                        to: Number($0),
                        sideEffect: sideEffect
                    )
                })
            )
            .fixedSize()
        }
    }

    func detail(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.body)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
                .font(.footnote)
                .contextMenu {
                    Button("Copy") {
                        UIPasteboard.general.string = value
                    }
                }
        }
    }

    func detail<T>(_ label: String, value: T) -> some View where T: CustomStringConvertible {
        detail(label, value: "\(value)")
    }
}
