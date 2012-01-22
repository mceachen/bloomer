require 'bitarray'
require 'digest/md5'

class Bloomer
  VERSION = "0.0.3"

  def initialize(capacity, false_positive_probability = 0.001)
    @capacity = capacity.round
    # m is the required number of bits in the array
    m = -(capacity * Math.log(false_positive_probability)) / (Math.log(2) ** 2)
    @ba = BitArray.new(m.round)
    # count is the number of unique additions to this filter.
    @count = 0
    # k is the number of hash functions that minimizes the probability of false positives
    @k = (Math.log(2) * (@ba.size / capacity)).round
  end

  # returns true if item did had not already been added
  def add string
    count = 0
    hashes(string).each { |ea| count += @ba[ea]; @ba[ea] = 1 }
    previously_included = (count == @k)
    @count += 1 unless previously_included
    !previously_included
  end

  # returns false if the item hadn't already been added
  # returns true if it is likely that string had been added. See #false_positive_probability
  def include? string
    !hashes(string).any? { |ea| @ba[ea] == 0 }
  end

  # The number of unique strings given to #add (including false positives, which can mean
  # this number under-counts)
  def count
    @count
  end

  # If count exceeds capacity, the provided #false_positive_probability will probably be exceeded.
  def capacity
    @capacity
  end

  private

  # Return an array of hash indices to set.
  # Uses triple hashing as described in http://www.ccs.neu.edu/home/pete/pub/bloom-filters-verification.pdf
  def hashes(data)
    m = @ba.size
    h = Digest::MD5.hexdigest(data.to_s).to_i(16)
    x = h % m
    h /= m
    y = h % m
    h /= m
    z = h % m
    [x] + 1.upto(@k - 1).collect do |i|
      x = (x + y) % m
      y = (y + z) % m
      x
    end
  end

  # Automatically expanding bloom filter.
  # See http://gsd.di.uminho.pt/members/cbm/ps/dbloom.pdf
  class Scalable
    S = 2
    R = Math.log(2) ** 2
    def initialize(initial_capacity = 256, false_positive_probability = 0.001)
      @false_positive_probability = false_positive_probability
      @bloomers = [Bloomer.new(initial_capacity, false_positive_probability * R)]
    end

    def capacity
      @bloomers.last.capacity
    end

    def count
      @bloomers.inject(0) {|i,b|i + b.count}
    end

    def add string
      l = @bloomers.last
      r = l.add(string)
      if r && (l.count > l.capacity)
        @bloomers << Bloomer.new(l.capacity * S, @false_positive_probability * (R**@bloomers.size))
      end
      r
    end

    # only return false if no bloomers include string.
    def include? string
      @bloomers.any? { |ea| ea.include? string }
    end
  end
end
