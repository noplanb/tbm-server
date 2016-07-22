class ModelWrapper
  class WrapperNotExist < Exception; end

  module WrapWith
    def wrap_with(*wrappers)
      wrappers.inject(self) do |memo, wrapper|
        klass = "#{self.class}::Wrappers::#{wrapper.to_s.camelize}"
        begin
          klass.constantize.new(memo)
        rescue NameError
          raise WrapperNotExist, wrapper
        end
      end
    end
  end

  attr_reader :model

  def initialize(model)
    @model = model
  end

  def method_missing(method, *args, &block)
    block ?
      model.send(method, *args, &block) :
      model.send(method, *args)
  end
end
