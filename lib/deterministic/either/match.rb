module Deterministic::Either
  def match(proc=nil, &block)
    match = Match.new(self)
    match.instance_eval &(proc || block)
    match.result
  end

  class Match
    def initialize(either)
      @either     = either
      @collection = []
    end

    def success(value=nil, &block)
      q(:success, value, block)
    end

    def failure(value=nil, &block)
      q(:failure, value, block)
    end

    def either(value=nil, &block)
      q(:either, value, block)
    end

    def result
      matcher = @collection.select { |m| m.first.call(@either.value) }.last
      matcher.last.call(@either.value)
    end

  private
    def q(type, condition, block)
      if condition.nil?
        condition_p = ->(v) { true }
      elsif condition.is_a?(Proc)
        condition_p = condition
      else
        condition_p = ->(v) { condition == @either.value }
      end

      @collection << [condition_p, block] if @either.is? type
    end
  end
end