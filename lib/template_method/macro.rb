module TemplateMethod
  module Macro
    def template_method_macro(method_name, &implementation)
      implementation ||= proc { |*| nil }

      if method_defined?(method_name, true) || private_method_defined?(method_name, true)
        return
      end

      default_method_name = :"_#{method_name}_default"

      define_method(default_method_name, &implementation)

      define_method(method_name) do |*args, **kwargs, &block|
        if defined?(super)
          super(*args, **kwargs, &block)
        else
          public_send(default_method_name, *args, **kwargs, &block)
        end
      end
    end
    alias :template_method :template_method_macro

    def template_method_variant_macro(method_name)
      template_method_macro(method_name) do |*|
        raise TemplateMethod::Error, "Implementation is required (Method name: #{method_name})"
      end
    end
    alias :template_method! :template_method_variant_macro

    def self.macro_methods
      [
        'template_method',
        'template_method!'
      ]
    end
  end
end
