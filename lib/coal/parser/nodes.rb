module Coal
  module Nodes
    module Helper
      def self.spaced_list e
        arr = [e[0]]
        e[1].each do |sub|
          arr << sub[1]
        end
        arr
      end
      
      def self.comma_separated_list e
        arr = [e[0]]
        e[1].each do |sub|
          arr << sub[3]
        end
        arr
      end
    end
    
    class Treetop::Runtime::SyntaxNode
      include Enumerable
      
      def [](i)
        elements[i]
      end
      
      def each &block
        elements.each &block
      end
    end
    
    class BaseNode < Treetop::Runtime::SyntaxNode
      def initialize *args, &block
        super
        init(elements) if respond_to? :init
      end
    end
    
    class Identifier < BaseNode
      def name
        text_value
      end
    end
    
    class Constant < BaseNode
      attr_reader :value
    end
    
    class IntegerConstant < Constant
      attr_reader :suffix, :base
      
      def init e
        @value = e[0].value
        @base = case e[0]
        when DecimalConstant
          10
        when OctalConstant
          8
        when HexadecimalConstant
          16
        end
        @suffix = []
        
        unless e[1].empty?
          suffix_str = e[1].text_value.downcase
          if suffix_str.include? 'll'
            @suffix << 'll'
          elsif suffix_str.include? 'l'
            @suffix << 'l'
          end
          if suffix_str.include? 'u'
            @suffix << 'u'
          end
        end
      end
    end
    
    class DecimalConstant < Constant
      def init e
        @value = text_value.to_i
      end
    end
    
    class OctalConstant < Constant
      def init e
        @value = text_value.to_i(8)
      end
    end
    
    class HexadecimalConstant < Constant
      def init e
        @value = text_value.to_i(16)
      end
    end
    
    class FloatingConstant < Constant
      attr_reader :suffix
      
      def init e
        @suffix = nil
        unless e.last.empty?
          @suffix = e.last.text_value.downcase
        end
      end
    end
    
    class DecimalFloatingConstant < FloatingConstant
      def init e
        super
        @value = e[0].text_value.to_f
        unless e[1].empty?
          @value *= 10 ** e[1].text_value[1..-1].to_i
        end
      end
    end
    
    class HexadecimalFloatingConstant < FloatingConstant
      def init e
        super
        a, b = *e[2].text_value.split('.')
        @value = a.to_i(16)
        @value += b.to_i(16).to_f / 16 ** b.size if b
        bin_exp = e[3].text_value[1..-1].to_i
        @value *= 2.0 ** bin_exp
      end
    end
    
    class EscapeSequence < BaseNode
      attr_reader :value
      
      MAP = {
        '\''  => 39,
        '"'   => 34,
        '?'   => 63,
        '\\'  => 92,
        'a'   => 7,
        'b'   => 8,
        'f'   => 12,
        'n'   => 10,
        'r'   => 13,
        't'   => 9,
        'v'   => 11,
      }
      
      def init e
        esc = text_value[1..-1]
        @value = MAP[esc]
        if @value.nil?
          if esc[0] == ?x
            @value = esc[1..-1].to_i(16)
          else
            @value = esc.to_i(8)
          end
        end
      end
    end
    
    class CharacterConstant < Constant
      def init e
        @wide = !e[0].empty? and e[0] == 'L'
        raise "Wide characters currently not supported" if @wide
        guts = e[2][0]
        if guts.is_a? EscapeSequence
          @value = guts.value
        else
          @value = guts.text_value[0]
        end
      end
      
      def wide?
        @wide
      end
    end
    
    class StringLiteral < BaseNode
      attr_reader :value
      
      def init e
        @wide = !e[0].empty? and e[0] == 'L'
        raise "Wide characters currently not supported" if @wide
        if e[2].empty?
          @value = ""
        else
          arr = e[2].map do |chr|
            if chr.is_a? EscapeSequence
              chr.value
            else
              chr.text_value[0]
            end
          end
          @value = arr.pack('c*')
        end
      end
      
      def wide?
        @wide
      end
    end
    
    class PrimaryExpression < BaseNode
      attr_reader :expression
      
      def init e
        @expression = e[2]
      end
    end
    
    class PostfixExpression < BaseNode
      # TODO
    end
    
    class UnaryExpression < BaseNode
      attr_reader :operand
    end
    
    class PrefixIncrement < UnaryExpression
      def init e
        @operand = e[2]
      end
    end
    
    class PrefixDecrement < UnaryExpression
      def init e
        @operand = e[2]
      end
    end
    
    class SizeOf < UnaryExpression
      def init e
        if e.size == 4
          @operand = e[3]
        else
          @operand = e[4]
        end
      end
    end
    
    class CastExpression < BaseNode
      attr_reader :operand, :type
      
      def init e
        @type = e[2]
        @operand = e[6]
      end
    end
    
    class LTRBinaryExpression < BaseNode
      attr_reader :operations
      
      def init e
        @operations = e[0].elements.map{|sub| [sub[0], sub[2].text_value]}.flatten
        @operations << e[1]
      end
    end
    
    class MultiplicativeExpression < LTRBinaryExpression ; end
    class AdditiveExpression < LTRBinaryExpression ; end
    class ShiftExpression < LTRBinaryExpression ; end
    class RelationalExpression < LTRBinaryExpression ; end
    class EqualityExpression < LTRBinaryExpression ; end
    class AndExpression < LTRBinaryExpression ; end
    class ExclusiveOrExpression < LTRBinaryExpression ; end
    class InclusiveOrExpression < LTRBinaryExpression ; end
    class LogicalAndExpression < LTRBinaryExpression ; end
    class LogicalOrExpression < LTRBinaryExpression ; end
    
    class ConditionalExpression < BaseNode
      attr_accessor :condition, :true_expression, :false_expression
      
      def init e
        @condition = e[0]
        @true_expression = e[4]
        @false_expression = e[8]
      end
    end
    
    class AssignmentExpression < BaseNode
      attr_accessor :lvalue, :operator, :rvalue
      
      def init e
        @lvalue = e[0]
        @operator = e[2].text_value
        @rvalue = e[4]
      end
    end
    
    class ExpressionList < BaseNode
      attr_reader :expressions
      
      def init e
        @expressions = Helper.comma_separated_list e
      end
    end
    
    class DeclarationStart < BaseNode
      attr_reader :specifier, :next
      
      def init e
        @specifier = e[0]
        @next = e[3]
      end
    end
    
    class Declaration < BaseNode
      attr_reader :specifiers, :inits
      
      def init e
        if e[0].is_a? DeclarationSpecifiers
          @specifiers = e[0]
        else
          @specifiers = []
          item = e[0]
          while item.is_a? DeclarationStart
            @specifiers << item.specifier
            item = item.next
          end
          @specifiers << item[0]
          @inits = Helper.comma_separated_list(item[3])
        end
      end
    end
    
    class DeclarationSpecifiers < BaseNode
    end
    
    class InitDeclarator < BaseNode
      attr_accessor :declarator, :initializer
      
      def init e
        @declarator = e[0]
        @initializer = e[4]
      end
    end
    
    class InitializerList < BaseNode
    end
    
    class TypeSpecifier < BaseNode ; end
    
    class VoidTypeSpecifier < TypeSpecifier ; end
    class CharTypeSpecifier < TypeSpecifier ; end
    class ShortTypeSpecifier < TypeSpecifier ; end
    class IntTypeSpecifier < TypeSpecifier ; end
    class LongTypeSpecifier < TypeSpecifier ; end
    class FloatTypeSpecifier < TypeSpecifier ; end
    class DoubleTypeSpecifier < TypeSpecifier ; end
    class SignedTypeSpecifier < TypeSpecifier ; end
    class UnsignedTypeSpecifier < TypeSpecifier ; end
    
    class PointerDeclarator < BaseNode
    end
    
    class ParenthesizedDeclarator < BaseNode
      attr_reader :declarator
      
      def init e
        @declarator = e[2]
      end
    end
    
    class ArrayDeclaratorEnd < BaseNode
      attr_reader :type_qualifiers, :size
      
      def init e
        if e[2].text_value == 'static'
          #TODO
          @size = e[-3]
        elsif e[4].text_value == 'static'
          @type_qualifiers = Helper.spaced_list e[2]
          @size = e[-3]
        elsif e.size == 5
          #TODO
        elsif e.size == 6
          #TODO
        else
          raise "array declarator node mismatch"
        end
      end
    end
    
    class FunctionDeclaratorEnd < BaseNode
      attr_reader :identifiers, :parameter_declarations
      
      def init e
        if e.size == 5
          decls = e[2]
          if decls.is_a? VariadicParameterTypeList
            raise 'varargs currently unsupported'
          end
          decls = Helper.comma_separated_list decls
          @parameter_declarations = decls
        elsif e.size == 4
          if e[2].empty?
            @identifiers = []
          else
            @identifiers = Helper.comma_separated_list e[2][0]
          end
        else
          raise "function declarator node mismatch"
        end
      end
    end
    
    class DirectDeclarator < BaseNode
      attr_reader :stem, :suffixes
      
      def init e
        @stem = e[0]
        while @stem.is_a? ParenthesizedDeclarator
          @stem = @stem.declarator
        end
        @suffixes = e[2].elements
      end
    end
    
    class VariadicParameterTypeList < BaseNode
      attr_reader :parameter_list
      
      def init e
        @parameter_list = e[0]
      end
    end
    
    class ParameterDeclaration < BaseNode
      attr_reader :declaration_specifiers, :declarator
      
      def init e
        @declaration_specifiers = [e[0]]
        if e[3].is_a? ParameterDeclaration
          @declaration_specifiers.concat e[3].declaration_specifiers
          @declarator = e[3].declarator
        else
          @declarator = e[3]
        end
      end
    end
    
    #...
    
    class Statement < BaseNode ; end
    
    class CompoundStatement < Statement
      attr_reader :statements
      
      def init e
        @statements = []
        unless e[2].empty?
          @statements = Helper.spaced_list e[2][0]
        end
        @statements.reject do |s|
          # Discard empty statements
          s.is_a? ExpressionStatement and s.expression.nil?
        end
      end
    end
    
    class ExpressionStatement < Statement
      attr_reader :expression
      
      def init e
        unless e[0].empty?
          @expression = e[0][0];
        end
      end
    end
    
    #...
    
    class SelectionStatement < Statement ; end
    
    class IfStatement < SelectionStatement
      attr_reader :condition, :then_statement, :else_statement
      
      def init e
        @condition = e[4]
        @then_statement = e[8]
        if e[12].nil?
          @else_statement = nil
        else
          @else_statement = e[12]
        end
      end
    end
    
    class IterationStatement < Statement ; end
    
    class WhileLoop < IterationStatement
      attr_reader :condition, :statement
      
      def init e
        @condition = e[4]
        @statement = e[8]
      end
    end
    
    class DoWhileLoop < IterationStatement
      attr_reader :condition, :statements
      
      def init e
        @condition = e[9]
        s = e[3]
        if s.is_a? CompoundStatement
          @statements = s.statements
        else
          @statements = [s]
        end
      end
    end
    
    #...
    
    class JumpStatement < Statement ; end
    
    class GotoStatement < JumpStatement
      attr_reader :label
      
      def init e
        @label = e[2]
      end
    end
    
    class ContinueStatement < JumpStatement
    end
    
    class BreakStatement < JumpStatement
    end
    
    class ReturnStatement < JumpStatement
      attr_reader :expression
      
      def init e
        @expression = e[2][1] unless e[2].empty?
      end
    end
    
    class TranslationUnit < BaseNode
      # Get array of function definitions and declarations
      attr_reader :items
      
      def init e
        @items = [e[1]]
        unless e[2].empty?
          @items.concat(e[2].map {|sub| sub[1]})
        end
      end
    end
    
    class FunctionDefinitionStart < BaseNode
    end
    
    class FunctionDefinition < BaseNode
      attr_reader :declarator, :declaration_specifiers
      attr_reader :declaration_list, :statements
      
      def init e
        @declaration_specifiers = []
        
        thing = e[0]
        while thing.is_a? FunctionDefinitionStart
          @declaration_specifiers << thing[0]
          thing = thing[3]
        end
        @declaration_specifiers << thing[0]
        @declarator = thing[3]
        
        @declaration_list = e[2].empty? ? [] : Helper.spaced_list(e[5][1])
        @statements = e[4].statements
      end
    end
  end
end

