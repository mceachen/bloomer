require "msgpack"

module Msgpackable
  def self.included(base)
    base.extend(ClassMethods)
  end

  def to_msgpack
    self.class.msgpack_factory.dump self
  end

  module ClassMethods
    def from_msgpack(data)
      msgpack_factory.load(data)
    end

    def msgpack_factory
      @msgpack_factory ||= ::MessagePack::Factory.new.tap do |factory|
        factory.register_type(0x01, ::Bloomer)
        factory.register_type(0x02, ::Bloomer::Scalable)
        factory.freeze
      end
    end
  end
end

# Patch Bloomer and Scalable to make them msgpackable
class Bloomer
  include Msgpackable

  def to_msgpack_ext
    self.class.msgpack_factory.dump([@capacity, @count, @k, @ba.size, @ba.field])
  end

  def from_msgpack_ext(capacity, count, k, ba_size, ba_field)
    @capacity, @count, @k = capacity, count, k
    @ba = BitArray.new(ba_size, ba_field)
  end

  def self.from_msgpack_ext(data)
    values = msgpack_factory.load(data)
    ::Bloomer.new(values[1]).tap do |b|
      b.from_msgpack_ext(*values)
    end
  end

  class Scalable
    include Msgpackable

    def to_msgpack_ext
      self.class.msgpack_factory.dump([@false_positive_probability, @bloomers])
    end

    def from_msgpack_ext(false_positive_probability, bloomers)
      @false_positive_probability, @bloomers = false_positive_probability, bloomers
    end

    def self.from_msgpack_ext(data)
      false_positive_probability, bloomers = msgpack_factory.load(data)
      ::Bloomer::Scalable.new.tap do |b|
        b.from_msgpack_ext(false_positive_probability, bloomers)
      end
    end
  end
end
