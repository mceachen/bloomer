require "spec_helper"

def rand_alpha(size)
  chars = ('a'..'z').to_a + ('A'..'Z').to_a
  (0...size).collect { chars[Kernel.rand(chars.length)] }.join
end

describe Bloomer do

  it "should work trivially" do
    b = Bloomer.new(*Bloomer.optimal_values(10, 0.001))
    b.add("a")
    b.should include("a")
    b.should_not include("")
    b.should_not include("b")
    b.add("b")
    b.should include("b")
    b.should_not include("")
    b.add("")
    b.should include("")
  end

  it "should find random strings" do
    b = Bloomer.new(*Bloomer.optimal_values(5_000, 0.001))
    inputs = 1000.times.collect { rand_alpha(Kernel.rand(50)) }
    inputs.each { |ea| b.add(ea) }
    inputs.each { |ea| b.include?(ea).should be_true }
    5000.times.each do
      s = rand_alpha(Kernel.rand(50))
      b.include?(s).should == inputs.include?(s)
    end
  end

  it "should marshal state correctly"
end
