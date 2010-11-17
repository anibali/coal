require 'coal/translators/translator'
require 'libjit'

module Coal::Translators
  class LibJIT < Translator
    attr_reader :namespace, :context
    
    def initialize namespace
      @namespace = namespace
      @context = JIT::Context.new
      @prototypes = {}
      @function_deps = {}
    end
    
    def preprocess node
      code = ""
      
      unless node[1].empty?
        group_parts = Helper.spaced_list(node[1][0])
        group_parts.each do |gp|
          case gp
          when TextLine
            code << gp.text_value
          when IncludeDirective
            if gp.tokens.one? and gp.tokens.first.is_a? HeaderName
              header_name = gp.tokens.first.name
              # TODO: formulate a nice way of doing this kind of thing, move
              # this elsewhere
              if header_name == "math.h"
                [
                  [
                    "pow", [:float64, :float64], :float64, lambda do |f|
                      f.return(f.arg(0) ** f.arg(1))
                    end
                  ],[
                    "powf", [:float32, :float32], :float32, lambda do |f|
                      f.return(f.arg(0) ** f.arg(1))
                    end
                  #],[
                  #  "powl", [:floatn, :floatn], :floatn, lambda do |f|
                  #    f.return(f.arg(0) ** f.arg(1))
                  #  end
                  ]
                ].each do |name, param_types, return_type, llama|
                  proto = Prototype.allocate
                  proto.instance_variable_set :@name, name
                  func = @context.build_function param_types, return_type, &llama
                  proto.instance_variable_set :@function, func
                  
                  @prototypes[proto.name] = proto
                  @function_deps[proto.function] = []
                  @namespace.add_function! proto.name, proto.function
                end
              end
            else
              raise "unsupported preprocessor directive: #{gp.text_value.strip}"
            end
          else
            raise "unsupported preprocessor directive: #{gp.text_value.strip}"
          end
        end
      end
      
      return code
    end
    
    def translate node
      return if node[1].empty?
      root_node = node[1][0]
      
      root_node.items.each do |item|
        if item.is_a? FunctionDefinition
          function(item)
        else
          assert_type item, Declaration
          
          if item.inits[0].is_a? DirectDeclarator and item.inits[0].suffixes[0].is_a? FunctionDeclaratorEnd
            specifiers = item.specifiers
            declarator = item.inits[0]
            prototype(specifiers, declarator)
          else
            raise "TODO: support global declarations"
          end
        end
      end
    end
    
    def function(node)
      assert_type node, FunctionDefinition
      
      proto = prototype(node.declaration_specifiers, node.declarator)
      
      @reg = {}
      
      begin
        @context.build do |c|
          @function = proto.function
          @function_deps[@function] = []
          proto.param_names.each_with_index do |name, i|
            @reg[name] = @function.arg(i)
          end
          statements(node.statements)
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
        trans.assert_type declarator, DirectDeclarator
        
        # TODO: support other declarator types
        trans.assert_type declarator.stem, Identifier
        @name = String(declarator.stem.name)
        
        param_types = []
        @param_names = []
        if declarator.suffixes.one?
          suffix = declarator.suffixes[0]
          trans.assert_type suffix, FunctionDeclaratorEnd
          
          if suffix.parameter_declarations.nil?
            unless suffix.identifiers.empty?
              raise "identifier-list style function definitions not supported yet"
            end
          else
            trans.assert_type suffix.parameter_declarations, Array
            suffix.parameter_declarations.each do |decl|
              trans.assert_type decl, ParameterDeclaration
              param_types << trans.declaration_specifiers(decl.declaration_specifiers)
              trans.assert_type decl.declarator, Identifier
              @param_names << decl.declarator.name
            end
          end
        else
          raise "can't understand function definitions with multiple suffixes"
        end
        
        trans.assert_type specifiers, Array
        return_type = trans.declaration_specifiers(specifiers)
        
        trans.context.build do
          @function = trans.context.function(param_types, return_type)
        end
      end
    end
    
    def statements(array)
      array.each do |node|
        statement(node)
      end
    end
    
    def statement(node)
      case node
      when CompoundStatement
        statements(node.statements)
      when ExpressionStatement
        expression(node.expression)
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
        @function.return(expression(node.expression))
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
          if init.initializer.is_a? InitializerList
            raise "TODO: initializer lists"
          else
            @reg[name].store expression(init.initializer)
          end
        end
      end
    end
    
    def expression(node)
      case node
      when IntegerConstant
        integer_constant(node)
      when FloatingConstant
        floating_constant(node)
      when Identifier
        var = @reg[node.name]
        raise "undeclared variable '#{node.name}'" if var.nil?
        var
      when PrimaryExpression
        expression(node.expression)
      when PostfixExpression
        node.suffixes.inject(node.operand) do |operand, suffix|
          case suffix
          when PostfixFunctionCall
            if operand.is_a? Identifier
              proto = @prototypes[String(operand.name)]
              @function_deps[@function] << proto.function
              args = suffix.arguments.map {|arg| expression(arg)}
              @function.call_other proto.function, *args
            else
              raise "calling function pointers currently unsupported"
            end
          else
            raise "unrecognised postfix expression suffix: #{suffix}"
          end
        end
      when PrefixIncrement
        lvalue = expression(node.operand)
        lvalue.store(lvalue + @function.const(1, :intn))
      when PrefixDecrement
        lvalue = expression(node.operand)
        lvalue.store(lvalue - @function.const(1, :intn))
      when LTRBinaryExpression
        ltr_binary_expression(node)
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
      when AssignmentExpression
        if node.operator == '='
          expression(node.lvalue).store expression(node.rvalue)
        else
          lvalue = expression(node.lvalue)
          rvalue = lvalue.send node.operator[0].chr, expression(node.rvalue)
          lvalue.store rvalue
        end
      when ExpressionList
        node.expressions.inject(nil) do |_, expr|
          expression(expr)
        end
      else
        raise "unrecognised expression node: #{node}"
      end
    end
    
    def ltr_binary_expression(node)
      assert_type node, LTRBinaryExpression
      
      ops = node.operations.dup
      a = expression(ops.slice! 0)
      until ops.empty?
        operator, b = *ops.slice!(0..1)
        b = expression(b)
        a = case operator
        when *%w[* / % + - << >> < <= > >= & | ^]
          a.send(operator, b)
        when '=='
          a.eq b
        when '!='
          a.ne b
        when '||'
          a.or b
        when '&&'
          a.and b
        else
          raise "unrecognised left-to-right binary operator: #{operator}"
        end
      end
      a
    end
    
    def declaration_specifiers(array)
      type_specifiers array.select {|s| s.is_a? TypeSpecifier}
    end
    
    def type_specifiers(array)
      array.each do |e|
        assert_type e, TypeSpecifier
      end
      array = array.map {|s| s.text_value}.sort
      
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

