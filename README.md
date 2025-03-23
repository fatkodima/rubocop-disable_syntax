# rubocop-disable_syntax

[![Build Status](https://github.com/fatkodima/rubocop-disable_syntax/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/fatkodima/rubocop-disable_syntax/actions/workflows/ci.yml)

`rubocop-disable_syntax` is a [RuboCop](https://github.com/rubocop/rubocop) plugin that allows to disable some unfavorite ruby syntax such as `unless`, safe navigation etc.

## Requirements

- ruby 2.7+
- rubocop 1.50+

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rubocop-disable_syntax', group: :development, require: false
```

And then run:

```sh
$ bundle install
```

## Usage

You need to tell RuboCop to load the `rubocop-disable_syntax` extension.

Put this into your `.rubocop.yml`.

```yaml
plugins:
  - rubocop-disable_syntax
```

**Note**: The plugin system is supported in RuboCop 1.72+. In earlier versions, use `require` instead of `plugins`.

All the ruby syntax features are enabled by default and so this gem acts as a no-op. You need to manually configure
which ruby features you want to disable:

```yml
Style/DisableSyntax:
  DisableSyntax:
    - unless
    - ternary
    - safe_navigation
    - endless_methods
    - arguments_forwarding
    - numbered_parameters
    - pattern_matching
    - shorthand_hash_syntax
    - and_or_not
    - until
    - percent_literals
```

* `unless` - no `unless` keyword
* `ternary` - no ternary operator (`condition ? foo : bar`)
* `safe_navigation` - no safe navigation operator (`&.`)
* `endless_methods` - no endless methods (`def foo = 1`)
* `arguments_forwarding` - no arguments forwarding (`foo(...)`, `foo(*)`, `foo(**)`, `foo(&)`)
* `numbered_parameters` - no numbered parameters (`foo.each { puts _1 }`)
* `pattern_matching` - no pattern matching
* `shorthand_hash_syntax` - no shorthand hash syntax (`{ x:, y: }`)
* `and_or_not` - no `and`/`or`/`not` keywords (should use `&&`/`||`/`!` instead)
* `until` - no `until` keyword
* `percent_literals` - no any `%` style literals (`%w[foo bar]`, `%i[foo bar]`, `%q("str")`, `%r{/regex/}`)

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake` to run the linter and tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fatkodima/rubocop-disable_syntax.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
