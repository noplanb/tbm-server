class ModelDecorator < SimpleDelegator
  class DecoratorNotExist < Exception; end

  module DecorateWith
    def decorate_with(*decorators)
      decorators.inject(self) do |memo, decorator|
        klass = "#{self.class}::Decorators::#{decorator.to_s.camelize}"
        begin
          klass.constantize.new(memo)
        rescue NameError
          raise DecoratorNotExist, wrapper
        end
      end
    end
  end

  def model
    __getobj__
  end
end
