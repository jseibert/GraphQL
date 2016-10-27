let __Schema = try! GraphQLObjectType(
    name: "__Schema",
    description:
    "A GraphQL Schema defines the capabilities of a GraphQL server. It " +
    "exposes all available types and directives on the server, as well as " +
    "the entry points for query, mutation, and subscription operations.",
    fields: [
        "types": GraphQLField(
            type: GraphQLNonNull(GraphQLList(GraphQLNonNull(__Type))),
            description: "A list of all types supported by this server.",
            resolve: { schema, _, _, _ in
                guard let schema = schema as? GraphQLSchema else {
                    return Map.null
                }

                let typeMap = schema.typeMap
                return Array(typeMap.values).sorted(by: { $0.name < $1.name })
            }
        ),
        "queryType": GraphQLField(
            type: GraphQLNonNull(__Type),
            description: "The type that query operations will be rooted at.",
            resolve: { schema, _, _, _ in
                guard let schema = schema as? GraphQLSchema else {
                    return Map.null
                }

                return schema.queryType
            }
        ),
        "mutationType": GraphQLField(
            type: __Type,
            description:
            "If this server supports mutation, the type that " +
            "mutation operations will be rooted at.",
            resolve: { schema, _, _, _ in
                guard let schema = schema as? GraphQLSchema else {
                    return Map.null
                }

                return schema.mutationType
            }
        ),
        "subscriptionType": GraphQLField(
            type: __Type,
            description:
            "If this server support subscription, the type that " +
            "subscription operations will be rooted at.",
            resolve: { schema, _, _, _ in
                guard let schema = schema as? GraphQLSchema else {
                    return Map.null
                }

                return schema.subscriptionType
            }
        ),
        "directives": GraphQLField(
            type: GraphQLNonNull(GraphQLList(GraphQLNonNull(__Directive))),
            description: "A list of all directives supported by this server.",
            resolve: { schema, _, _, _ in
                guard let schema = schema as? GraphQLSchema else {
                    return Map.null
                }

                return schema.directives
            }
        )
    ]
)

let __Directive = try! GraphQLObjectType(
    name: "__Directive",
    description:
    "A Directive provides a way to describe alternate runtime execution and " +
    "type validation behavior in a GraphQL document." +
    "\n\nIn some cases, you need to provide options to alter GraphQL\"s " +
    "execution behavior in ways field arguments will not suffice, such as " +
    "conditionally including or skipping a field. Directives provide this by " +
    "describing additional information to the executor.",
    fields: [
        "name": GraphQLField(type: GraphQLNonNull(GraphQLString)),
        "description": GraphQLField(type: GraphQLString),
        "locations": GraphQLField(
            type: GraphQLNonNull(GraphQLList(GraphQLNonNull(__DirectiveLocation)))
        ),
        "args": GraphQLField(
            type: GraphQLNonNull(GraphQLList(GraphQLNonNull(__InputValue))),
            resolve: { directive, _, _, _ in
                guard let directive = directive as? GraphQLDirective else {
                    return Map.null
                }

                return directive.args
            }
        ),
    ]
)

let __DirectiveLocation = try! GraphQLEnumType(
    name: "__DirectiveLocation",
    description:
    "A Directive can be adjacent to many parts of the GraphQL language, a " +
    "__DirectiveLocation describes one such possible adjacencies.",
    values: [
        "QUERY": GraphQLEnumValue(
            value: DirectiveLocation.query.rawValue.map,
            description: "Location adjacent to a query operation."
        ),
        "MUTATION": GraphQLEnumValue(
            value: DirectiveLocation.mutation.rawValue.map,
            description: "Location adjacent to a mutation operation."
        ),
        "SUBSCRIPTION": GraphQLEnumValue(
            value: DirectiveLocation.subscription.rawValue.map,
            description: "Location adjacent to a subscription operation."
        ),
        "FIELD": GraphQLEnumValue(
            value: DirectiveLocation.field.rawValue.map,
            description: "Location adjacent to a field."
        ),
        "FRAGMENT_DEFINITION": GraphQLEnumValue(
            value: DirectiveLocation.fragmentDefinition.rawValue.map,
            description: "Location adjacent to a fragment definition."
        ),
        "FRAGMENT_SPREAD": GraphQLEnumValue(
            value: DirectiveLocation.fragmentSpread.rawValue.map,
            description: "Location adjacent to a fragment spread."
        ),
        "INLINE_FRAGMENT": GraphQLEnumValue(
            value: DirectiveLocation.inlineFragment.rawValue.map,
            description: "Location adjacent to an inline fragment."
        ),
        "SCHEMA": GraphQLEnumValue(
            value: DirectiveLocation.schema.rawValue.map,
            description: "Location adjacent to a schema definition."
        ),
        "SCALAR": GraphQLEnumValue(
            value: DirectiveLocation.scalar.rawValue.map,
            description: "Location adjacent to a scalar definition."
        ),
        "OBJECT": GraphQLEnumValue(
            value: DirectiveLocation.object.rawValue.map,
            description: "Location adjacent to an object type definition."
        ),
        "FIELD_DEFINITION": GraphQLEnumValue(
            value: DirectiveLocation.fieldDefinition.rawValue.map,
            description: "Location adjacent to a field definition."
        ),
        "ARGUMENT_DEFINITION": GraphQLEnumValue(
            value: DirectiveLocation.argumentDefinition.rawValue.map,
            description: "Location adjacent to an argument definition."
        ),
        "INTERFACE": GraphQLEnumValue(
            value: DirectiveLocation.interface.rawValue.map,
            description: "Location adjacent to an interface definition."
        ),
        "UNION": GraphQLEnumValue(
            value: DirectiveLocation.union.rawValue.map,
            description: "Location adjacent to a union definition."
        ),
        "ENUM": GraphQLEnumValue(
            value: DirectiveLocation.enum.rawValue.map,
            description: "Location adjacent to an enum definition."
        ),
        "ENUM_VALUE": GraphQLEnumValue(
            value: DirectiveLocation.enumValue.rawValue.map,
            description: "Location adjacent to an enum value definition."
        ),
        "INPUT_OBJECT": GraphQLEnumValue(
            value: DirectiveLocation.inputObject.rawValue.map,
            description: "Location adjacent to an input object type definition."
        ),
        "INPUT_FIELD_DEFINITION": GraphQLEnumValue(
            value: DirectiveLocation.inputFieldDefinition.rawValue.map,
            description: "Location adjacent to an input object field definition."
        ),
    ]
)

let __Type: GraphQLObjectType = try! GraphQLObjectType(
    name: "__Type",
    description:
    "The fundamental unit of any GraphQL Schema is the type. There are " +
    "many kinds of types in GraphQL as represented by the `__TypeKind` enum." +
    "\n\nDepending on the kind of a type, certain fields describe " +
    "information about that type. Scalar types provide no information " +
    "beyond a name and description, while Enum types provide their values. " +
    "Object and Interface types provide the fields they describe. Abstract " +
    "types, Union and Interface, provide the Object types possible " +
    "at runtime. List and NonNull types compose other types.",
    fields: [
        "kind": GraphQLField(
            type: GraphQLNonNull(__TypeKind),
            resolve: { type, _, _, _ in
                switch type {
                case let type as GraphQLScalarType:
                    return TypeKind.scalar
                case let type as GraphQLObjectType:
                    return TypeKind.object
                case let type as GraphQLInterfaceType:
                    return TypeKind.interface
                case let type as GraphQLUnionType:
                    return TypeKind.union
                case let type as GraphQLEnumType:
                    return TypeKind.enum
                case let type as GraphQLInputObjectType:
                    return TypeKind.inputObject
                case let type as GraphQLList:
                    return TypeKind.list
                case let type as GraphQLNonNull:
                    return TypeKind.nonNull
                default:
                    throw GraphQLError(message: "Unknown kind of type: \(type)")
                }
            }
        ),
        "name": GraphQLField(type: GraphQLString),
        "description": GraphQLField(type: GraphQLString),
        "fields": GraphQLField(
            type: GraphQLList(GraphQLNonNull(__Field)),
            args: [
                "includeDeprecated": GraphQLArgument(
                    type: GraphQLBoolean,
                    defaultValue: false
                )
            ],
            resolve: { type, arguments, _, _ in
                if let type = type as? GraphQLObjectType {
                    let fieldMap = type.fields
                    var fields = Array(fieldMap.values).sorted(by: { $0.name < $1.name })

                    if !arguments["includeDeprecated"].bool! {
                        fields = fields.filter({ !$0.isDeprecated })
                    }

                    return fields
                }

                return Map.null
            }
        ),
        "interfaces": GraphQLField(
            type: GraphQLList(GraphQLNonNull(GraphQLTypeReference("__Type"))),
            resolve: { type, _, _, _ in
                if let type = type as? GraphQLObjectType {
                    return type.interfaces
                }

                return Map.null
            }
        ),
        "possibleTypes": GraphQLField(
            type: GraphQLList(GraphQLNonNull(GraphQLTypeReference("__Type"))),
            resolve: { type, args, context, info in
                if let type = type as? GraphQLAbstractType {
                    return info.schema.getPossibleTypes(abstractType: type)
                }

                return Map.null
            }
        ),
        "enumValues": GraphQLField(
            type: GraphQLList(GraphQLNonNull(__EnumValue)),
            args: [
                "includeDeprecated": GraphQLArgument(
                    type: GraphQLBoolean,
                    defaultValue: false
                )
            ],
            resolve: { type, arguments, _, _ in
                if let type = type as? GraphQLEnumType {
                    var values = type.values

                    if !arguments["includeDeprecated"].bool! {
                        values = values.filter({ !$0.isDeprecated })
                    }
                    
                    return values
                }

                return Map.null
            }
        ),
        "inputFields": GraphQLField(
            type: GraphQLList(GraphQLNonNull(__InputValue)),
            resolve: { type, _, _, _ in
                if let type = type as? GraphQLInputObjectType {
                    let fieldMap = type.fields
                    return Array(fieldMap.values).sorted(by: { $0.name < $1.name })
                }
                
                return Map.null
            }
        ),
        "ofType": GraphQLField(type: GraphQLTypeReference("__Type"))
    ]
)

let __Field = try! GraphQLObjectType(
    name: "__Field",
    description:
    "Object and Interface types are described by a list of Fields, each of " +
    "which has a name, potentially a list of arguments, and a return type.",
    fields: [
        "name": GraphQLField(type: GraphQLNonNull(GraphQLString)),
        "description": GraphQLField(type: GraphQLString),
        "args": GraphQLField(
            type: GraphQLNonNull(GraphQLList(GraphQLNonNull(__InputValue))),
            resolve: { field, _, _, _ in
                guard let field = field as? GraphQLFieldDefinition else {
                    return Map.null
                }

                return field.args
            }
        ),
        "type": GraphQLField(type: GraphQLNonNull(GraphQLTypeReference("__Type"))),
        "isDeprecated": GraphQLField(type: GraphQLNonNull(GraphQLBoolean)),
        "deprecationReason": GraphQLField(type: GraphQLString)
    ]
)

let __InputValue = try! GraphQLObjectType(
    name: "__InputValue",
    description:
    "Arguments provided to Fields or Directives and the input fields of an " +
    "InputObject are represented as Input Values which describe their type " +
    "and optionally a default value.",
    fields: [
        "name": GraphQLField(type: GraphQLNonNull(GraphQLString)),
        "description": GraphQLField(type: GraphQLString),
        "type": GraphQLField(type: GraphQLNonNull(GraphQLTypeReference("__Type"))),
        "defaultValue": GraphQLField(
            type: GraphQLString,
            description:
            "A GraphQL-formatted string representing the default value for this " +
            "input value.",
            resolve: { inputValue, _, _, _ in
                guard let inputValue = inputValue as? GraphQLArgumentDefinition else {
                    return Map.null
                }

                guard let defaultValue = inputValue.defaultValue else {
                    return Map.null
                }

                // This `print` is from the AST printer implementation
//                return print(astFromValue(value: defaultValue, type: inputValue.type))
                return defaultValue
            }
        )
    ]
)

let __EnumValue = try! GraphQLObjectType(
    name: "__EnumValue",
    description:
    "One possible value for a given Enum. Enum values are unique values, not " +
    "a placeholder for a string or numeric value. However an Enum value is " +
    "returned in a JSON response as a string.",
    fields: [
        "name": GraphQLField(type: GraphQLNonNull(GraphQLString)),
        "description": GraphQLField(type: GraphQLString),
        "isDeprecated": GraphQLField(type: GraphQLNonNull(GraphQLBoolean)),
        "deprecationReason": GraphQLField(type: GraphQLString)
    ]
)

enum TypeKind : String {
    case scalar = "SCALAR"
    case object = "OBJECT"
    case interface = "INTERFACE"
    case union = "UNION"
    case `enum` = "ENUM"
    case inputObject = "INPUT_OBJECT"
    case list = "LIST"
    case nonNull = "NON_NULL"
    case typeReference = "TYPE_REFERENCE"
}

extension TypeKind : MapRepresentable {
    var map: Map {
        return rawValue.map
    }
}

let __TypeKind = try! GraphQLEnumType(
    name: "__TypeKind",
    description: "An enum describing what kind of type a given `__Type` is.",
    values: [
        "SCALAR": GraphQLEnumValue(
            value: TypeKind.scalar.rawValue.map,
            description: "Indicates this type is a scalar."
        ),
        "OBJECT": GraphQLEnumValue(
            value: TypeKind.object.rawValue.map,
            description: "Indicates this type is an object. " +
            "`fields` and `interfaces` are valid fields."
        ),
        "INTERFACE": GraphQLEnumValue(
            value: TypeKind.interface.rawValue.map,
            description: "Indicates this type is an interface. " +
            "`fields` and `possibleTypes` are valid fields."
        ),
        "UNION": GraphQLEnumValue(
            value: TypeKind.union.rawValue.map,
            description: "Indicates this type is a union. " +
            "`possibleTypes` is a valid field."
        ),
        "ENUM": GraphQLEnumValue(
            value: TypeKind.enum.rawValue.map,
            description: "Indicates this type is an enum. " +
            "`enumValues` is a valid field."
        ),
        "INPUT_OBJECT": GraphQLEnumValue(
            value: TypeKind.inputObject.rawValue.map,
            description: "Indicates this type is an input object. " +
            "`inputFields` is a valid field."
        ),
        "LIST": GraphQLEnumValue(
            value: TypeKind.list.rawValue.map,
            description: "Indicates this type is a list. " +
            "`ofType` is a valid field."
        ),
        "NON_NULL": GraphQLEnumValue(
            value: TypeKind.nonNull.rawValue.map,
            description: "Indicates this type is a non-null. " +
            "`ofType` is a valid field."
        ),
    ]
)

/**
 * Note that these are GraphQLFieldDefinition and not GraphQLField,
 * so the format for args is different.
 */

let SchemaMetaFieldDef = GraphQLFieldDefinition(
    name: "__schema",
    type: GraphQLNonNull(__Schema),
    description: "Access the current type schema of this server.",
    resolve: { _, _, _, info in
        return info.schema
    }
)

let TypeMetaFieldDef = GraphQLFieldDefinition(
    name: "__type",
    type: __Type,
    description: "Request the type information of a single type.",
    args: [
        GraphQLArgumentDefinition(
            name: "name",
            type: GraphQLNonNull(GraphQLString)
        )
    ],
    resolve: { _, arguments, _, info in
        let name = arguments["name"].string!
        return info.schema.getType(name: name)
    }
)

let TypeNameMetaFieldDef = GraphQLFieldDefinition(
    name: "__typename",
    type: GraphQLNonNull(GraphQLString),
    description: "The name of the current Object type at runtime.",
    resolve: { _, _, _, info in
        info.parentType.name
    }
)
