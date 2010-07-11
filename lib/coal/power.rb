module Coal
  module Power
    def self.included(klass)
      klass.extend ClassMethods
    end
    
    module ClassMethods
      def defc name, param_types, return_type, code
        name = name.to_sym
        callable = Coal.build_func param_types, return_type, code
        
        if name.to_s.match /^self\.(.*)/
          name = $1.to_sym
          class_eval "(@@coal_class_methods ||= {})[name] = callable"
        else
          class_eval "(@@coal_instance_methods ||= {})[name] = callable"
        end
      end
      
      def method_missing name, *args
        name = name.to_sym
        coal_methods = class_eval("@@coal_class_methods") rescue nil
        if coal_methods and coal_methods.has_key? name
          coal_methods[name].call *args
        else
          super
        end
      end
    end
    
    def method_missing name, *args
      name = name.to_sym
      coal_methods = self.class.class_eval("@@coal_instance_methods") rescue nil
      if coal_methods and coal_methods.has_key? name
        coal_methods[name].call *args
      else
        super
      end
    end
  end
end

