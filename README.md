# Minitestify

minitestify is a tool to convert Rspec specs to equivalent minitest tests by parsing and transforming the code using the [syntax_tree](https://github.com/ruby-syntax-tree/syntax_tree) gem.

It's early days and this work is still experimental.  Here's what it can do now

### Capabilities
- describe -> class
- context -> class
- it -> def test_*
- expect(actual).to eq(expected) -> assert_equal(expected, actual)
- expect(actual).to be_falsey -> refute(actual)
- expect(actual).to be_truthy -> assert(actual)

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add minitestify

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install minitestify

## Usage

```
Usage: minitestify [options] <spec_files>
    -v, --version                    Print version
    -h, --help                       Prints this help
    -r, --rails                      Use more railsy syntax
    -s, --save                       Replace spec with test in path & file name. Write to new file
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Testing

```
rake test
```

### Development Tips

Use the `stree` cli to output matchers.

```bash
=> stree expr -e 'expect(false).to be_falsey'
SyntaxTree::CommandCall[
  receiver: SyntaxTree::CallNode[
    receiver: nil,
    operator: nil,
    message: SyntaxTree::Ident[value: "expect"],
    arguments: SyntaxTree::ArgParen[
      arguments: SyntaxTree::Args[
        parts: [SyntaxTree::VarRef[value: SyntaxTree::Kw[value: "false"]]]
      ]
    ]
  ],
  operator: SyntaxTree::Period[value: "."],
  message: SyntaxTree::Ident[value: "to"],
  arguments: SyntaxTree::Args[
    parts: [SyntaxTree::VCall[value: SyntaxTree::Ident[value: "be_falsey"]]]
  ]
]
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/minitestify. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/minitestify/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Minitestify project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/minitestify/blob/master/CODE_OF_CONDUCT.md).
