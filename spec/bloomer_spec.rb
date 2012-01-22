require "spec_helper"
require "benchmark"

def rand_word(length = 8)
  ('a'..'z').to_a.shuffle.first(length).join # not random enough to cause hits.
end

describe Bloomer do
  it "should work trivially" do
    b = Bloomer.new(10, 0.001)
    b.add("a").should be_false
    b.add("a").should be_true
    b.should include("a")
    b.should_not include("")
    b.should_not include("b")
    b.add("b").should be_false
    b.add("b").should be_true
    b.should include("b")
    b.should_not include("")
    b.add("")
    b.should include("")
  end

  it "should marshal state correctly" do
    b = Bloomer.new(10, 0.001)
    inputs = %q(a b c d)
    inputs.each { |ea| b.add(ea) }
    s = Marshal.dump(b)
    new_b = Marshal.load(s)
    inputs.each { |ea| new_b.should include(ea) }
  end

  it "should result in similar-to-expected false positives" do
    max_false_prob = 0.001
    size = 50_000
    bloom = Bloomer.new(size, max_false_prob)
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
end
