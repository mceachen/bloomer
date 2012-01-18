# Bloomer: a pure-ruby bloom filter with no extra fluff

Need a bloom filter that can

* figure out what to do when given the general cardinality of the set, and a false-positive hit rate?
* use a robust set of hashing functions, such that millions of records can be handled correctly?
* marshal state quickly?
* not require EM or Redis or something else unrelated to simply implementing a bloom filter?

You've come to the right place!

## Example

```ruby
expected_size = 10_000
false_positive_probability = 0.01
b = Bloomer.new(*Bloomer.optimal_values(expected_size, false_positive_probability))
b.add "cat"
b.include? "cat"
#=> true
bf.include? "dog"
#=> false
```

## History

* 0.0.1 First post.


