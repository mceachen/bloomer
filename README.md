# Bloomer: Bloom filters with elastic

[![Gem Version](https://badge.fury.io/rb/bloomer.svg)](https://badge.fury.io/rb/bloomer)
[![Build Status](https://secure.travis-ci.org/mceachen/bloomer.svg)](http://travis-ci.org/mceachen/bloomer)

[Bloom filters](http://en.wikipedia.org/wiki/Bloom_filter) are great for quickly
checking to see if a given string has been seen before--in constant time, and
using a fixed amount of RAM, as long as you know the expected number of elements
up front. If you add more than `capacity` elements to the filter, accuracy for
`include?` will drop below `false_positive_probability`.

[Scalable Bloom Filters](http://gsd.di.uminho.pt/members/cbm/ps/dbloom.pdf)
maintain a maximal `false_positive_probability` by using additional RAM as
needed.

`Bloomer` is a Bloom Filter. `Bloomer::Scalable` is a Scalable Bloom Filter.

Keep in mind that **false positives with Bloom filters are expected**, with a
specified probability rate. False negatives, however, are not. In other words,

- if `include?` returns _false_, that string has _certainly not_ been `add`ed
- if `include?` returns _true_, it _might_ mean that string was `add`ed
  (depending on the `false_positive_probability` parameter provided to the
  constructor).

This implementation is unique in that Bloomer

- supports scalable bloom filters (SBF)
- uses triple hash chains (see [the paper](http://www.ccs.neu.edu/home/pete/pub/bloom-filters-verification.pdf))
- can marshal state quickly
- has rigorous tests
- is pure ruby
- does not require EM or Redis or something else unrelated to simply implementing a bloom filter

## Usage

```ruby
expected_size = 10_000
false_positive_probability = 0.01
b = Bloomer.new(expected_size, false_positive_probability)
b.add "cat"
b.include? "cat"
#=> true
bf.include? "dog"
#=> false
```

Scalable Bloom filters uses the same API:

```ruby
b = Bloomer::Scalable.new
b.add "boom"
b.include? "boom"
#=> true
bf.include? "badda"
#=> false
```

Serialization can be done using
[MessagePack](https://github.com/msgpack/msgpack-ruby):

Notice, you'll need to require `bloomer/msgpackable` to enable serialization.

```ruby
require 'bloomer/msgpackable'
b = Bloomer.new(10)
b.add("a")
s = b.to_msgpack
new_b = Bloomer.from_msgpack(s)
new_b.include? "a"
#=> true
```

The original class will be preserved regardless of calling
`Bloomer.from_msgpack(s)` or `Bloomer::Scalable.from_msgpack(s)`:

```ruby
require 'bloomer/msgpackable'
b = Bloomer::Scalable.new
b.add("a")
s = b.to_msgpack
new_b = Bloomer.from_msgpack(s)
new_b.class == Bloomer::Scalable
#=> true
```

## Changelog

### 1.0.0

- Using msgpack for more secure deserialization. Marshal.load still works but is
  not recommended

### 0.0.5

- Switched from rspec to minitest

### 0.0.4

- Fixed gem packaging

### 0.0.3

- Added support for scalable bloom filters (SBF)

### 0.0.2

- Switch to triple-hash chaining (simpler, faster, and better false-positive rate)

### 0.0.1

- Bloom, there it is.
