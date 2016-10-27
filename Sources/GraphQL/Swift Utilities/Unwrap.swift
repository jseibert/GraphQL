public func unwrap(_ value: MapRepresentable) -> MapRepresentable? {
    let mirror = Mirror(reflecting: value)

    if mirror.displayStyle != .optional {
        return value
    }

    if mirror.children.isEmpty {
        return nil
    }

    let child = mirror.children.first!
    return child.value as? MapRepresentable
}
