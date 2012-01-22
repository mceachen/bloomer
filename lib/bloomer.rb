require 'bitarray'
require 'digest/md5'

class Bloomer
  VERSION = "0.0.2"

  def initialize(expected_size, false_positive_probability = 0.001, opts = {})
    @ba = opts[:ba] || begin
      # m is the required number of bits in the array
      m = -(expected_size * Math.log(false_positive_probability)) / (Math.log(2) ** 2)
      BitArray.new(m.round)
    end
    # k is the number of hash functions that minimizes the probability of false positives
    @k = (opts[:k] || Math.log(2) * (@ba.size / expected_size)).round
  end

  # returns true if item hadn't already been added
  def add string
    count = 0
    hashes(string).each { |ea| count += @ba[ea] ; @ba[ea] = 1 }
    count == @k
  end

  # returns false if the item hadn't already been added
  # returns true if it is likely that string had been added. See #false_positive_probability
  def include? string
    !hashes(string).any? { |ea| @ba[ea] == 0 }
  end

  def _dump(depth)
    [@k, Marshal.dump(@ba)].join(" ")
  end

  def self._load(data)
    k, ba = data.split(" ", 2)
    new(nil, nil, :k => k.to_i, :ba => Marshal.load(ba))
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
end
