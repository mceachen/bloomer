require "spec_helper"
require "benchmark"

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
  set.each { |ea| bloom.include?(ea).should be_true }
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
  new_b.count.should == b.count
  new_b.capacity.should == b.capacity
  inputs.each { |ea| new_b.should include(ea) }
end

def test_simple(b)
  b.add("a").should be_true
  b.add("a").should be_false
  b.should include("a")
  b.should_not include("")
  b.should_not include("b")
  b.add("b").should be_true
  b.add("b").should be_false
  b.should include("b")
  b.should_not include("")
  b.add("")
  b.should include("")
end

describe Bloomer do
  it "should work trivially" do
    b = Bloomer.new(10, 0.001)
    test_simple(b)
  end

  it "should marshal state correctly" do
    b = Bloomer.new(10, 0.001)
    test_marshal_state(b)
  end

  it "should result in similar-to-expected false positives" do
    max_false_prob = 0.001
    size = 50_000
    b = Bloomer.new(size, max_false_prob)
    test_bloom(size, max_false_prob, b)
  end
end

describe Bloomer::Scalable do
  it "should work trivially" do
    b = Bloomer::Scalable.new
    test_simple(b)
  end

  it "should marshal state correctly" do
    b = Bloomer::Scalable.new(10, 0.001)
    100.times.each { b.add(rand_word) }
    test_marshal_state(b)
  end

  it "should result in similar-to-expected false positives" do
    max_false_prob = 0.001
    size = 10_000
    b = Bloomer::Scalable.new(1024, max_false_prob)
    test_bloom(size, max_false_prob, b)
  end

  it "should result in similar-to-expected false positives" do
    max_false_prob = 0.01
    size = 50_000
    b = Bloomer::Scalable.new(1024, max_false_prob)
    test_bloom(size, max_false_prob, b)
  end
end
