require "test_helper"

C = ('a'..'z').to_a

def rand_word(length = 8)
  C.shuffle.first(length).join # not random enough to cause hits.
end

def test_bloom(size, max_false_prob, bloom)
  set = Set.new
  size.times do
    w = rand_word
    bloom.add(w)
    set.add(w)
  end
  set.each { |ea| bloom.must_include(ea) }
  tries = size * 3
  false_hits = 0
  hits = 0
  tries.times.each do
    word = rand_word
    b_inc, s_inc = bloom.include?(word), set.include?(word)
    hits += 1 if s_inc
    if s_inc && !b_inc
      fail "'#{word}': false negative on include"
    elsif !s_inc && b_inc
      false_hits += 1
    end
  end

  false_positive_failure_rate = false_hits.to_f / tries
  puts "False positive rate = #{false_positive_failure_rate * 100}%, expected #{max_false_prob * 100}% (#{false_hits} false positives, #{hits} hits)"
  if (false_positive_failure_rate) > max_false_prob * 2
    fail "False-positive failure rate was bad: #{false_positive_failure_rate}"
  end
end

def test_marshal_state(b)
  inputs = b.capacity.times.collect { rand_word }
  inputs.each { |ea| b.add(ea) }
  new_b = Marshal.load(Marshal.dump(b))
  new_b.count.must_equal b.count
  new_b.capacity.must_equal b.capacity
  inputs.each { |ea| new_b.must_include(ea) }
end

def test_msgpackable(b)
  require "bloomer/msgpackable"
  inputs = b.capacity.times.collect { rand_word }
  inputs.each { |ea| b.add(ea) }
  packed = b.to_msgpack
  new_b = b.class.from_msgpack(packed)
  new_b.count.must_equal b.count
  new_b.capacity.must_equal b.capacity
  inputs.each { |ea| new_b.must_include(ea) }
  dump = Marshal.dump(b)
  packed.size.must_be :<, dump.size
  b.class.must_equal new_b.class
end

def test_simple(b)
  b.add("a").must_equal true
  b.add("a").must_equal false
  b.must_include("a")
  b.wont_include("")
  b.wont_include("b")
  b.add("b").must_equal true
  b.add("b").must_equal false
  b.must_include("b")
  b.wont_include("")
  b.add("")
  b.must_include("")
end

describe Bloomer do
  it "works trivially" do
    b = Bloomer.new(10, 0.001)
    test_simple(b)
  end

  it "marshals state correctly" do
    b = Bloomer.new(10, 0.001)
    test_marshal_state(b)
  end

  it "serializes and deserializes correctly" do
    b = Bloomer.new(10, 0.001)
    test_msgpackable(b)
  end

  it "results in similar-to-expected false positives" do
    max_false_prob = 0.001
    size = 50_000
    b = Bloomer.new(size, max_false_prob)
    test_bloom(size, max_false_prob, b)
  end
end

describe Bloomer::Scalable do
  it "works trivially" do
    b = Bloomer::Scalable.new
    test_simple(b)
  end

  it "marshals state correctly" do
    b = Bloomer::Scalable.new(10, 0.001)
    100.times.each { b.add(rand_word) }
    test_marshal_state(b)
  end

  it "serializes and deserializes correctly" do
    b = Bloomer::Scalable.new(10, 0.001)
    100.times.each { b.add(rand_word) }
    test_msgpackable(b)
  end

  it "results in similar-to-expected false positives" do
    max_false_prob = 0.001
    size = 10_000
    b = Bloomer::Scalable.new(1024, max_false_prob)
    test_bloom(size, max_false_prob, b)
  end

  it "results in similar-to-expected false positives" do
    max_false_prob = 0.01
    size = 50_000
    b = Bloomer::Scalable.new(1024, max_false_prob)
    test_bloom(size, max_false_prob, b)
  end
end
