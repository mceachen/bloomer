# Bloomer: a pure-ruby bloom filter with no extra fluff


[Bloom filters](http://en.wikipedia.org/wiki/Bloom_filter) are great for quickly checking to see if
a given string has been seen before--in constant time, and using a fixed amount of RAM.

Note that false positives with bloom filters *are possible*, but false negatives are not.

In other words,

* if ```include?``` returns true, it *might* mean that string was ```add```ed
* if ```include?``` returns ```false```, that string has *certainly not* been ```add```ed

This implementation is the Nth bloom filter gem written in ruby -- but, at the time of conception, the only one that

* uses a robust set of hashing functions
* can marshal state quickly
* does not require EM or Redis or something else unrelated to simply implementing a bloom filter

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

Serialization is through [Marshal](http://ruby-doc.org/core-1.8.7/Marshal.html):

```ruby
b = Bloomer.new(10)
b.add("a")
s = Marshal.dump(b)
new_b = Marshal.load(s)
new_b.include? "a"
#=> true
```

## History

* 0.0.1 Bloom, there it is.


