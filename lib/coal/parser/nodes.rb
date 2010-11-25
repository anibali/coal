module Coal
  module Nodes
    class Identifier
      attr_reader :name
      
      def initialize name
        @name = name
      end
    end
    
    class Constant
      attr_reader :value
    end
    
    class IntegerConstant < Constant
      attr_reader :base, :suffix
      
      def initialize value, base, suffix
        @value = value
        @base = base
        @suffix = suffix
      end
    end

    class FloatingConstant < Constant
      attr_reader :base, :suffix
      
      def initialize value, base, suffix
        @value = value
        @base = base
        @suffix = suffix
      end
    end

    class CharacterConstant < Constant
      def initialize value, wide
        @value = value
        @wide = wide
        raise "Wide characters currently not supported" if wide?
      end
      
      def wide?
        @wide
      end
    end
    
    class StringLiteral
      attr_reader :value
      
      def initialize value, wide
        @value = value
        @wide = wide
        raise "Wide strings currently not supported" if wide?
      end
      
      def wide?
        @wide
      end
    end
    
    class PostfixExpression
      attr_reader :operand
      
      def initialize operand
        @operand = operand
      end
    end

    class FunctionCall < PostfixExpression
      attr_reader :arguments
      
      def initialize operand, arguments
        super(operand)
        @arguments = arguments
      end
    end

    class StructMember < PostfixExpression
      attr_reader :field
      
      def initialize operand, field, direct
        super(operand)
        @field = field
        @direct = direct
      end
      
      def direct?
        @direct
      end
    end
    
    class PostfixIncrement < PostfixExpression ; end
    class PostfixDecrement < PostfixExpression ; end
    
    class Subscript < PostfixExpression
      attr_reader :index
      
      def initialize operand, index
        super(operand)
        @index = index
      end
    end

    class UnaryExpression
      attr_reader :operand
      
      def initialize operand
        @operand = operand
      end
    end
    
    class PrefixIncrement < UnaryExpression ; end
    class PrefixDecrement < UnaryExpression ; end
    class Dereference < UnaryExpression ; end
    class AddressOf < UnaryExpression ; end
    class Positive < UnaryExpression ; end
    class Negative < UnaryExpression ; end
    class BitwiseComplement < UnaryExpression ; end
    class LogicalNot < UnaryExpression ; end
    
    class SizeOf < UnaryExpression
      def initialize operand, type
        super(operand)
        @type = type
      end
      
      def type?
        @type
      end
    end

    class CastExpression
      attr_reader :operand, :type
      
      def initialize operand, type
        @operand = operand
        @type = type
      end
    end
    
    class BinaryArithmeticExpression
      attr_reader :operands
      
      def initialize a, b
        @operands = [a, b]
      end
    end
    
    class Multiply < BinaryArithmeticExpression ; end
    class Divide < BinaryArithmeticExpression ; end
    class Modulo < BinaryArithmeticExpression ; end
    class Add < BinaryArithmeticExpression ; end
    class Subtract < BinaryArithmeticExpression ; end
    class LeftBitshift < BinaryArithmeticExpression ; end
    class RightBitshift < BinaryArithmeticExpression ; end
    
    class LessOrEqual < BinaryArithmeticExpression ; end
    class Less < BinaryArithmeticExpression ; end
    class GreaterOrEqual < BinaryArithmeticExpression ; end
    class Greater < BinaryArithmeticExpression ; end
    class Equal < BinaryArithmeticExpression ; end
    class NotEqual < BinaryArithmeticExpression ; end
    
    class BitwiseAnd < BinaryArithmeticExpression ; end
    class BitwiseXor < BinaryArithmeticExpression ; end
    class BitwiseOr < BinaryArithmeticExpression ; end
    
    class LogicalAnd < BinaryArithmeticExpression ; end
    class LogicalOr < BinaryArithmeticExpression ; end

    class ConditionalExpression
      attr_accessor :condition, :true_expression, :false_expression
      
      def initialize condition, true_expression, false_expression
        @condition = condition
        @true_expression = true_expression
        @false_expression = false_expression
      end
    end
    
    class Assign
      attr_accessor :lvalue, :rvalue
      
      def initialize lvalue, rvalue
        @lvalue = lvalue
        @rvalue = rvalue
      end
    end

    class Declaration
      attr_reader :specifiers, :inits
      
      def initialize specifiers, inits=[]
        @specifiers = specifiers
        @inits = inits
      end
    end

    class InitDeclarator
      attr_accessor :declarator, :initializer
      
      def initialize declarator, initializer
        @declarator = declarator
        @initializer = initializer
      end
    end
    
    class ArrayDeclarator
      attr_reader :declarator, :type_qualifiers, :expression
      
      def initialize declarator, type_qualifiers, expression, static
        @declarator = declarator
        @type_qualifiers = type_qualifiers
        @expression = expression
        @static = static
      end
      
      def static?
        @static
      end
    end
    
    class FunctionDeclarator
      attr_reader :declarator, :parameter_declarations, :identifiers
      
      def initialize declarator, parameter_declarations, identifiers
        @declarator = declarator
        @parameter_declarations = parameter_declarations
        @identifiers = identifiers
      end
      
      def identifiers?
        @parameter_declarations.nil?
      end
      
      def parameter_declarations?
        !identifiers?
      end
    end

    class ParameterDeclaration
      attr_reader :specifiers, :declarator
      
      def initialize specifiers, declarator
        @specifiers = specifiers
        @declarator = declarator
      end
    end
    
    #...
    
    class Statement ; end
    
    class ExpressionStatement < Statement
      attr_reader :expression
      
      def initialize expression
        @expression = expression
      end
    end
    
    class CaseStatement < Statement
      attr_reader :expression, :statement
      
      def initialize expression, statement
        @expression = expression
        @statement = statement
      end
    end
    
    class SelectionStatement < Statement ; end
    
    class IfStatement < SelectionStatement
      attr_reader :condition, :then_statement, :else_statement
      
      def initialize condition, then_statement, else_statement=nil
        @condition = condition
        @then_statement = then_statement
        @else_statement = else_statement
      end
    end
    
    class IterationStatement < Statement ; end
    
    class WhileLoop < IterationStatement
      attr_reader :condition, :statement
      
      def initialize condition, statement
        @condition = condition
        @statement = statement
      end
    end
    
    class DoWhileLoop < IterationStatement
      attr_reader :condition, :statement
      
      def initialize condition, statement
        @condition = condition
        @statement = statement
      end
    end
    
    class ForLoop < IterationStatement
      attr_reader :initializer, :condition, :incrementer, :statement
      
      def initialize initializer, condition, incrementer, statement
        @initializer = initializer
        @condition = condition
        @incrementer = incrementer
        @statement = statement
      end
    end
    
    #...
    
    class JumpStatement < Statement ; end
    
    class GoToStatement < JumpStatement
      attr_reader :label
      
      def initialize label
        @label = label
      end
    end
    
    class ContinueStatement < JumpStatement ; end
    class BreakStatement < JumpStatement ; end
    
    class ReturnStatement < JumpStatement
      attr_reader :value
      
      def initialize value=nil
        @value = value
      end
    end
    
    class FunctionDefinition
      attr_reader :declaration_specifiers, :declarator
      attr_reader :declaration_list, :statement
      
      def initialize declaration_specifiers, declarator, declaration_list, statement
        @declaration_specifiers = declaration_specifiers
        @declarator = declarator
        @declaration_list = declaration_list
        @statement = statement
      end
    end
    
    ################
    # Preprocessor #
    ################
    
    class HeaderName
      attr_reader :name
      
      def initialize name
        @name = name
      end
    end
    
    class AngledHeaderName < HeaderName ; end
    class QuotedHeaderName < HeaderName ; end

    class IncludeDirective
      attr_accessor :tokens
      
      def initialize tokens
        @tokens = tokens
      end
    end
    
  end # End module Nodes
end # End module Coal

class Treetop::Runtime::SyntaxNode
  include Enumerable
  
  def [](i)
    elements[i]
  end
  
  def each &block
    elements.each &block
  end
  
  def ltr_binomial_tree ops
    expr = elements[0].tree
    elements[1].each do |e|
      expr = ops[e[1].text_value].new(expr, e[3].tree)
    end
    expr
  end
end

