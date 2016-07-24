class ModelDecorator < SimpleDelegator
  class DecoratorNotExist < Exception; end

  module DecorateWith
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def decorator(value)
        klass = "#{name}::Decorators::#{value.to_s.camelize}"
        begin
          klass.constantize
        rescue NameError
          raise DecoratorNotExist, value
        end
      end
    end

    def decorate_with(*decorators)
      decorators.inject(self) do |memo, decorator|
        self.class.decorator(decorator).new(memo)
      end
    end
  end

  def model
    __getobj__.model rescue __getobj__
  end

  def kind_of?(klass)
    self.class == klass || __getobj__.kind_of?(klass)
  end
end
