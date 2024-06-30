public enum ObjectError: Error {
    case invalid(String)
}

/// An object representation that can be stored in a Git repository.
public protocol Object: Identifiable, Equatable, Hashable {
    /// The id of the object.
    var id: OID { get }

    /// The type of the object.
    var type: ObjectType { get }
}
