import libgit2

public enum TreeError: Error {
    case invalid(String)
}

/// A tree representation in the repository.
///
/// A tree object is a directory listing. It contains a list of entries, each of which contains a SHA-1 reference to a
/// blob or subtree with its associated mode, type, and filename.
///
/// Trees are used to represent the contents of a directory. They are also used to represent the contents of a commit.
///
/// Trees are similar to directories in a filesystem, but they are stored as a single file in the Git repository.
public struct Tree: Object {
    /// The id of the tree.
    public let id: OID

    /// The entries in the tree.
    public let entries: [Entry]

    /// The type of the object.
    public let type: ObjectType = .tree

    init(pointer: OpaquePointer) throws {
        // Get the id of the tree
        let id = git_tree_id(pointer)

        guard let id = id?.pointee else {
            let errorMessage = String(cString: git_error_last().pointee.message)
            throw TreeError.invalid(errorMessage)
        }

        // Get the number of entries in the tree
        let entryCount = git_tree_entrycount(pointer)

        // Get all the entries in the tree
        var entries = [Entry]()

        for index in 0 ..< entryCount {
            let entryPointer = git_tree_entry_byindex(pointer, index)

            guard let entryPointer else {
                throw TreeError.invalid("Invalid tree entry")
            }

            let entry = try Entry(pointer: entryPointer)
            entries.append(entry)
        }

        self.id = OID(raw: id)
        self.entries = entries
    }
}

public extension Tree {
    // ? Should we conform to Object?
    /// Represents an entry in a Git tree object.
    struct Entry: Identifiable, Equatable, Hashable {
        /// The OID of the object pointed to by the entry
        public let id: OID

        /// The filename of the entry
        public let name: String

        /// The type of the object pointed to by the entry (blob, tree or commit)
        public let type: ObjectType

        /// The file mode of the entry (permissions)
        public let mode: FileMode

        init(pointer: OpaquePointer) throws {
            let id = git_tree_entry_id(pointer)
            let name = git_tree_entry_name(pointer)
            let type = git_tree_entry_type(pointer)
            let mode = git_tree_entry_filemode(pointer)

            guard let id, let name else {
                throw TreeError.invalid("Invalid tree entry")
            }

            self.id = OID(raw: id.pointee)
            self.name = String(cString: name)
            self.type = ObjectType(raw: type)
            self.mode = FileMode(raw: mode)
        }
    }
}
