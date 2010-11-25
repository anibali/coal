module Coal::Translators
  class LibJIT < Translator
    attr_reader :namespace, :context
    
    def initialize namespace
      @namespace = namespace
      @context = JIT::Context.new
      @prototypes = {}
      @function_deps = {}
      @special_functions = {}
    end
    
    def add_function name, function
      name = String(name)
      proto = Prototype.allocate
      proto.instance_variable_set :@name, name
      proto.instance_variable_set :@function, function
      @prototypes[name] = proto
    end
    
    def add_special_function name, method=nil, &block
      name = String(name)
      if block_given?
        @special_functions[name] = block
      else
        @special_functions[name] = method
      end
    end
    
    def preprocess node
      code = ""
      
      node.each do |gp|
        case gp
        when String
          code << gp
        when IncludeDirective
          if gp.tokens.one? and gp.tokens.first.is_a? HeaderName
            Includes.add self, gp.tokens.first.name
          else
            raise "unsupported preprocessor directive"
          end
        else
          raise "unsupported preprocessor directive"
        end
      end
      
      return code
    end
    
    def translate node
      return if node.empty?
      
      node.each do |item|
        if item.is_a? FunctionDefinition
          function(item)
        else
          raise "TODO: global declarations"
        end
      end
    end
    
    def function(node)
      proto = prototype(node.declaration_specifiers, node.declarator)
      
      @reg = {}
      
      begin
        @context.build do |c|
          @function = proto.function
          @function_deps[@function] = []
          proto.param_names.each_with_index do |name, i|
            @reg[name] = @function.arg(i)
          end
          statement(node.statement)
        end
      rescue Exception => ex
        @context.build_end
        raise ex
      end
      
      @reg = @function = nil
      
      @namespace.add_function! proto.name, proto.function
    end
    
    # Prepare a function for calling
    def prepare_function function
      unless function.compiled?
        # Prepare each other function which may be called by this function
        @function_deps[function].each do |f|
          prepare_function f
        end
        # Compile the function unless it is already compiled
        function.compile
      end
    end
    
    def prototype(specifiers, declarator)
      proto = Prototype.new(self, specifiers, declarator)
      # TODO: combine prototypes (make sure param names are there, etc)
      # rather than keeping first prototype as concrete
      @prototypes[proto.name] ||= proto
    end
    
    class Prototype
      include Coal::Nodes
      
      attr_reader :name, :param_names, :function
      
      def initialize trans, specifiers, declarator
        # TODO: support non-Identifier declarator types
        @name = String(declarator.declarator.name)
        
        param_types = []
        @param_names = []
        if declarator.identifiers?
          unless declarator.identifiers.empty?
            raise "identifier-list style function definitions not supported yet"
          end
        else
          declarator.parameter_declarations.each do |decl|
            param_types << trans.declaration_specifiers(decl.specifiers)
            # TODO: support non-Identifier declarator types
            @param_names << decl.declarator.name
          end
        end
        
        return_type = trans.declaration_specifiers(specifiers)
        
        trans.context.build do
          @function = trans.context.function(param_types, return_type)
        end
      end
    end
    
    def statement(node)
      case node
      when Array
        node.each do |node|
          statement(node)
        end
      when ExpressionStatement
        expression(node.expression) unless node.expression.nil?
      when IfStatement
        part = @function.if { expression(node.condition) }.do {
          statement(node.then_statement)
        }
        if node.else_statement.nil?
          part.end
        else
          part.else { statement(node.else_statement) }.end
        end
      when WhileLoop
        @function.while { expression(node.condition) }.do {
          statement(node.statement)
        }.end
      when ReturnStatement
        @function.return(expression(node.value))
      when Declaration
        declaration(node)
      else
        raise "unrecognised statement node: #{node}"
      end
    end
    
    def declaration(node)
      type = declaration_specifiers(node.specifiers)
      node.inits.each do |init|
        declarator = init.is_a?(InitDeclarator) ? init.declarator : init
        # TODO: support other declarator types
        assert_type declarator, Identifier
        name = String(declarator.name)
        @reg[name] = @function.declare(type)
        if init.is_a? InitDeclarator
          if init.initializer.is_a? Array
            raise "TODO: initializer lists"
          else
            @reg[name].store expression(init.initializer)
          end
        end
      end
    end
    
    def expression(node)
      case node
      when Array
        node.inject(nil) do |_, expr|
          expression(expr)
        end
      when IntegerConstant
        integer_constant(node)
      when FloatingConstant
        floating_constant(node)
      when Identifier
        var = @reg[node.name]
        raise "undeclared variable '#{node.name}'" if var.nil?
        var
      when StringLiteral
        @function.stringz node.value
      when FunctionCall
        if node.operand.is_a? Identifier
          name = String(node.operand.name)
          args = node.arguments.map {|arg| expression(arg)}
          if @special_functions[name]
            @special_functions[name].call @function, *args
          else
            proto = @prototypes[name]
            @function_deps[@function] << proto.function
            @function.call_other proto.function, *args
          end
        else
          raise "calling function pointers currently unsupported"
        end
      when UnaryExpression
        case node
        when PrefixIncrement
          lvalue = expression(node.operand)
          lvalue.store(lvalue + @function.const(1, :intn))
        when PrefixDecrement
          lvalue = expression(node.operand)
          lvalue.store(lvalue - @function.const(1, :intn))
        when Dereference:       expression(node.operand).dereference
        when AddressOf:         expression(node.operand).address
        when Positive:          expression(node.operand)
        when Negative:          -expression(node.operand)
        when BitwiseComplement: ~expression(node.operand)
        when LogicalNot:        expression(node.operand).not
        else
          raise "unrecognised unary operator: #{node.operator}"
        end
      when BinaryArithmeticExpression
        binary_arithmetic_expression(node)
      when ConditionalExpression
        # TODO: Somehow do this with only one if statement
        t = f = nil
        cond = expression(node.condition)
        
        @function.if { cond }.do {
          t = expression(node.true_expression)
        }.else {
          f = expression(node.false_expression)
        }.end
        
        type = t.type.size < f.type.size ? f.type : t.type
        tmp = @function.declare type
        
        @function.if { cond }.do {
          tmp.store t
        }.else {
          tmp.store f
        }.end
        
        tmp
      when Assign
        rvalue = expression(node.rvalue)
        
        if node.lvalue.is_a? Dereference
          expression(node.lvalue.operand).mstore rvalue
        else
          expression(node.lvalue).store rvalue
        end
      else
        raise "unrecognised expression node: #{node}"
      end
    end
    
    def binary_arithmetic_expression(node)
      assert_type node, BinaryArithmeticExpression
      
      a, b = *(node.operands.map {|expr| expression(expr)})
      
      case node
      when Multiply:        a * b
      when Divide:          a / b
      when Modulo:          a % b
      when Add:             a + b
      when Subtract:        a - b
      when LeftBitshift:    a << b
      when RightBitshift:   a >> b
      when LessOrEqual:     a <= b
      when Less:            a < b
      when GreaterOrEqual:  a >= b
      when Greater:         a > b
      when Equal:           a.eq b
      when NotEqual:        a.ne b
      when BitwiseAnd:      a & b
      when BitwiseXor:      a ^ b
      when BitwiseOr:       a | b
      when LogicalAnd:      a.and b
      when LogicalOr:       a.or b
      else
        raise "unrecognised binary arithmetic expression: #{node}"
      end
    end
    
    def declaration_specifiers(array)
      #TODO: process qualifiers, etc
      type_specifiers array
    end
    
    def type_specifiers(array)
      array.sort!
      
      hash = {}
      [
        ['void', :void],
        ['char', :int8],
        ['signed char', :int8],
        ['unsigned char', :uint8],
        ['short', 'signed short', 'short int', 'signed short int', :int16],
        ['unsigned short', 'unsigned short int', :uint16],
        ['int', 'signed', 'signed int', :int32],
        ['unsigned', 'unsigned int', :uint32],
        ['long', 'signed long', 'long int', 'signed long int', :intn],
        ['unsigned long', 'unsigned long int', :uintn],
        ['long long', 'signed long long', 'long long int',
          'signed long long int', :int64],
        ['unsigned long long', 'unsigned long long int', :uint64],
        ['float', :float32],
        ['double', :float64],
        ['long double', :floatn],
        ['_Bool', :bool],
      ].each do |a|
        a[0..-2].each do |k|
          hash[k.split.sort] = a.last
        end
      end
      type = hash[array]
      raise "unrecognised type: #{array.join ' '}" if type.nil?
      type
    end
    
    def integer_constant(node)
      assert_type node, IntegerConstant
      
      native_bits = JIT::Type.create(:uintn).size * 8
      base = node.base
      value = node.value
      type = case node.suffix.sort
      when ['ll', 'u']
        :uint64
      when ['ll']
        if base == 10 or value < 2 ** 63
          :int64
        else
          :uint64
        end
      when ['l', 'u']
        if value < 2 ** native_bits
          :uintn
        else
          :uint64
        end
      when ['l']
        if value < 2 ** (native_bits - 1)
          :intn
        elsif base != 10 and value < 2 ** native_bits
          :uintn
        elsif base == 10 or value < 2 ** 63
          :int64
        else
          :uint64
        end
      when ['u']
        if value < 2 ** 32
          :uint32
        elsif value < 2 ** native_bits
          :uintn
        else
          :uint64
        end
      when []
        if value < 2 ** 31
          :int32
        elsif base != 10 and value < 2 ** 32
          :uint32
        elsif value < 2 ** (native_bits - 1)
          :intn
        elsif base != 10 and value < 2 ** native_bits
          :uintn
        elsif base == 10 or value < 2 ** 63
          :int64
        else
          :uint64
        end
      else
        raise "unrecognised integer constant suffix: #{node.suffix.inspect}"
      end
      @function.const(value, type)
    end
    
    def floating_constant(node)
      value = node.value
      
      type = case node.suffix
        when 'f'
          :float32
        when 'l'
          :floatn
        when nil, ""
          :float64
        else
          raise "unrecognised floating constant suffix: #{node.suffix}"
      end
      
      @function.const(value, type)
    end
    
  end # End class LibJIT
end # End module Coal::Translators

