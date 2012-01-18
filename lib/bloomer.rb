require 'bitarray'

class Bloomer
  VERSION = "0.0.1"

  def initialize(expected_size, false_positive_probability = 0.001, opts = {})
    @ba = opts[:ba] || begin
      # m is the required number of bits in the array
      m = -(expected_size * Math.log(false_positive_probability)) / (Math.log(2) ** 2)
      BitArray.new(m.round)
    end

    # k is the number of hash functions that minimizes the probability of false positives
    k = opts[:k] || Math.log(2) * (@ba.size / expected_size)
    @hashes = Hashes.build(k.round)
  end

  def add string
    indicies(string).each { |ea| @ba[ea] = 1 }
  end

  def include? string
    !indicies(string).any? { |ea| @ba[ea] == 0 }
  end

  def _dump(depth)
    [@hashes.size, Marshal.dump(@ba)].join("\n")
  end

  def self._load(data)
    k, ba = data.split("\n", 2)
    new(nil, nil, :k => k.to_i, :ba => Marshal.load(ba))
  end

  private

  def indicies string
    @hashes.collect do |h|
      h.call(string) % @ba.size
    end
  end

  class CircularQueue < Array
    def rot!
      first = self.shift
      self.push(first)
      first
    end
  end

  class Hashes
    PRIMES = [3571, 4219, 4447, 5167, 5419, 6211, 7057, 7351, 8269, 9241, 10267, 11719, 12097, 13267, 13669, 16651, 19441, 19927, 22447, 23497, 24571, 25117, 26227, 27361, 33391, 35317]

    def self.build(number_of_hashes)
      hashes = [djb_hash, js_hash, rs_hash, knr_hash, ruby_hash]
      primes = CircularQueue.new PRIMES
      while (number_of_hashes > hashes.size)
        hashes += [:djb_hash, :js_hash, :rs_hash, :knr_hash, :ruby_hash].collect do |ea|
          send(ea, primes.rot!, primes.rot!)
        end
      end
      return hashes.first(number_of_hashes)
    end

    MAX = 2**31 - 1

    # written by Professor Daniel J. Bernstein from comp.lang.c
    def self.djb_hash(a = 5381, b = nil)
      lambda do |data|
        data.each_byte.inject(a) do |hash, ea|
          ((hash << 5) + hash + ea) % MAX
        end
      end
    end

    # bitwise hash function written by Justin Sobel
    def self.js_hash(a = 1315423911, b = nil)
      lambda do |data|
        data.each_byte.inject(a) do |hash, ea|
          (hash ^ ((hash << 5) + ea + (hash >> 2))) % MAX
        end
      end
    end

    # simple hash function from Robert Sedgwicks Algorithms in C book
    def self.rs_hash(a = 63689, b = 378551)
      lambda do |data|
        i, j = a, b
        data.each_byte.inject(0) do |hash, ea|
          i = (i * j) % MAX
          (hash * i + ea) % MAX
        end
      end
    end

    # From Kernigham and Ritchie's "The C Programming Language"
    def self.knr_hash(a = 1619, b = 911)
      lambda do |data|
        data.each_byte.inject(a) do |hash, ea|
          ((hash * b) + ea) % MAX
        end
      end
    end

    # default hash
    def self.ruby_hash(a = 1, b = 1)
      lambda do |data|
        (data.hash * a) % MAX
      end
    end
  end
end