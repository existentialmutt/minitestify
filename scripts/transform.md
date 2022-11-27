# How to add a transformation

Run the following in an irb session to determine the search pattern

```ruby
require "syntax_tree"

code = <<~RUBY
  expect(calculator.add(1, 1)).to eq(2)
RUBY

program = SyntaxTree.parse code
puts program.construct_keys
```

You'll get a bunch of output like this
```ruby
SyntaxTree::Program[
  statements: SyntaxTree::Statements[
    body: [
      SyntaxTree::CommandCall[
        receiver: SyntaxTree::CallNode[
          receiver: nil,
          operator: nil,
          message: SyntaxTree::Ident[value: "expect"],
          arguments: SyntaxTree::ArgParen[
            arguments: SyntaxTree::Args[
              parts: [
                SyntaxTree::CallNode[
                  receiver: SyntaxTree::VCall[
                    value: SyntaxTree::Ident[value: "calculator"]
                  ],
                  operator: SyntaxTree::Period[value: "."],
                  message: SyntaxTree::Ident[value: "add"],
                  arguments: SyntaxTree::ArgParen[
                    arguments: SyntaxTree::Args[
                      parts: [
                        SyntaxTree::Int[value: "1"],
                        SyntaxTree::Int[value: "1"]
                      ]
                    ]
                  ]
                ]
              ]
            ]
          ]
        ],
        operator: SyntaxTree::Period[value: "."],
        message: SyntaxTree::Ident[value: "to"],
        arguments: SyntaxTree::Args[
          parts: [
            SyntaxTree::CallNode[
              receiver: nil,
              operator: nil,
              message: SyntaxTree::Ident[value: "eq"],
              arguments: SyntaxTree::ArgParen[
                arguments: SyntaxTree::Args[
                  parts: [SyntaxTree::Int[value: "2"]]
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ]
]
```

We want the top level node of the body.  Remove the SyntaxTree namespaces and take just enough to identify the top node
```ruby
expect_eq_search =
    'CommandCall[
      receiver: CallNode[
        message: Ident[value: "expect"]
      ],
      operator: Period[value: "."],
      message: Ident[value: "to"],
      arguments: Args[
        parts: [ CallNode[
          message: Ident[value: "eq"]
          ]
        ]
      ]
    ]'
```

And use that as our argument to `visitor.mutate`
```ruby
visitor.mutate(expect_eq_search) do
  # ...
end
```

For the block body, start by pulling out relevant information with a pattern matching statement from construct_keys
TODO pare down the pattern match and extract variables
```ruby
node => SyntaxTree::CommandCall[
  receiver: SyntaxTree::CallNode[
    receiver: nil,
    operator: nil,
    message: SyntaxTree::Ident[value: "expect"],
    arguments: SyntaxTree::ArgParen[
      arguments: SyntaxTree::Args[parts: [actual_expr]]
    ]
  ],
  operator: SyntaxTree::Period[value: "."],
  message: SyntaxTree::Ident[value: "to"],
  arguments: SyntaxTree::Args[
    parts: [
      SyntaxTree::CallNode[
        receiver: nil,
        operator: nil,
        message: SyntaxTree::Ident[value: "eq"],
        arguments: SyntaxTree::ArgParen[
          arguments: SyntaxTree::Args[parts: [expected_expr]]
        ]
      ]
    ]
  ]
]
```

Now write the code you want to transform it to and construct the nodes

```ruby
require "syntax_tree"

code = <<~RUBY
  assert_equal(2, calculator.add(1, 1))
RUBY

program = SyntaxTree.parse code
puts program.construct_keys
```

Again you get a bunch of output
```ruby
SyntaxTree::Program[
  statements: SyntaxTree::Statements[
    body: [
      SyntaxTree::CallNode[
        receiver: nil,
        operator: nil,
        message: SyntaxTree::Ident[value: "assert_equal"],
        arguments: SyntaxTree::ArgParen[
          arguments: SyntaxTree::Args[
            parts: [
              SyntaxTree::Int[value: "2"],
              SyntaxTree::CallNode[
                receiver: SyntaxTree::VCall[
                  value: SyntaxTree::Ident[value: "calculator"]
                ],
                operator: SyntaxTree::Period[value: "."],
                message: SyntaxTree::Ident[value: "add"],
                arguments: SyntaxTree::ArgParen[
                  arguments: SyntaxTree::Args[
                    parts: [
                      SyntaxTree::Int[value: "1"],
                      SyntaxTree::Int[value: "1"]
                    ]
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ]
]
```

Add `.new` and convert parentheses.  You'll have to add `location: node.location` where required (trial and error).  Make this node tree the return value of the mutate block.

```ruby
expect_eq_search =
  'CommandCall[
    receiver: CallNode[
      message: Ident[value: "expect"]
    ],
    operator: Period[value: "."],
    message: Ident[value: "to"],
    arguments: Args[
      parts: [ CallNode[
        message: Ident[value: "eq"]
        ]
      ]
    ]
  ]'
visitor.mutate(expect_eq_search) do |node|
  node => SyntaxTree::CommandCall[
    receiver: SyntaxTree::CallNode[
      receiver: nil,
      operator: nil,
      message: SyntaxTree::Ident[value: "expect"],
      arguments: SyntaxTree::ArgParen[
        arguments: SyntaxTree::Args[parts: [actual_expr]]
      ]
    ],
    operator: SyntaxTree::Period[value: "."],
    message: SyntaxTree::Ident[value: "to"],
    arguments: SyntaxTree::Args[
      parts: [
        SyntaxTree::CallNode[
          receiver: nil,
          operator: nil,
          message: SyntaxTree::Ident[value: "eq"],
          arguments: SyntaxTree::ArgParen[
            arguments: SyntaxTree::Args[parts: [expected_expr]]
          ]
        ]
      ]
    ]
  ]

  SyntaxTree::CallNode.new(
    message:
      SyntaxTree::Ident.new(
        value: "assert_equal",
        location: node.location
      ),
    arguments:
      SyntaxTree::ArgParen.new(
        arguments:
          SyntaxTree::Args.new(
            parts: [expected_expr, actual_expr],
            location: node.location
          ),
        location: node.location
      ),
    location: node.location,
    receiver: nil,
    operator: nil
  )
end
```
