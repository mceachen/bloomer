# Bloomer: Bloom filters with elastic

[Bloom filters](http://en.wikipedia.org/wiki/Bloom_filter) are great for quickly checking to see if
a given string has been seen before--in constant time, and using a fixed amount of RAM, as long
as you know the expected number of elements up front. If you add more than ```capacity``` elements to the filter,
accuracy for ```include?``` will drop below ```false_positive_probability```.

[Scalable Bloom Filters](http://gsd.di.uminho.pt/members/cbm/ps/dbloom.pdf) maintain a maximal ```false_positive_probability```
by using additional RAM as needed.

```Bloomer``` is a Bloom Filter. ```Bloomer::Scalable``` is a Scalable Bloom Filter.

Keep in mind that **false positives with Bloom filters are expected**, with a specified probability rate.
False negatives, however, are not. In other words,

* if ```include?``` returns *false*, that string has *certainly not* been ```add```ed
* if ```include?``` returns *true*, it *might* mean that string was ```add```ed (depending on the
```false_positive_probability``` parameter provided to the constructor).

This implementation is unique in that Bloomer

* supports scalable bloom filters (SBF)
* uses triple hash chains (see [the paper](http://www.ccs.neu.edu/home/pete/pub/bloom-filters-verification.pdf))
* can marshal state quickly
* has rigorous tests
* is pure ruby
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

Scalable Bloom filters uses the same API:

```ruby
b = Bloomer::Scalable.new
b.add "boom"
b.include? "boom"
#=> true
bf.include? "badda"
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
* 0.0.2 Switch to triple-hash chaining (simpler, faster, and better false-positive rate)
* 0.0.3 Added support for scalable bloom filters (SBF)


