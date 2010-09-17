require 'ffi'

module Cl
  module GLib
    extend FFI::Library
    
    ffi_lib "glib-2.0"
    
    FUNCTIONS = {}
    
    def self.bind_function name, param_types, return_type
      attach_function name, param_types.dup, return_type
      
      addr = ffi_libraries.first.find_function String(name)
      func = FFI::Function.new(return_type, param_types, addr)
      FUNCTIONS[name] = [func, param_types, return_type]
    end
    
    # GQuark
    bind_function :g_quark_from_string, [:string], :uint32
    bind_function :g_quark_from_static_string, [:string], :uint32
    bind_function :g_quark_to_string, [:uint32], :string
    bind_function :g_quark_try_string, [:string], :uint32
    bind_function :g_intern_string, [:string], :string
    bind_function :g_intern_static_string, [:string], :string
    
    # GTimer
    bind_function :g_timer_new, [], :pointer
    bind_function :g_timer_start, [:pointer], :void
    bind_function :g_timer_stop, [:pointer], :void
    bind_function :g_timer_continue, [:pointer], :void
    bind_function :g_timer_elapsed, [:pointer, :ulong], :double
    bind_function :g_timer_reset, [:pointer], :void
    bind_function :g_timer_destroy, [:pointer], :void
    
    def self.libjit_call! trans, name, *args
      func, param_types, return_type = *FUNCTIONS[name.to_sym]
      param_types = param_types.dup
      
      variadic = param_types.last == :varargs
      param_types.slice!(-1) if variadic
      
      param_types.map! {|t| JIT::Type.from_ffi_type t}
      return_type = JIT::Type.from_ffi_type return_type
      
      signature = JIT::SignatureType.new(param_types, return_type)
      
      if variadic
        trans.function.call_native_variadic func, signature, *args
      else
        trans.function.call_native func, signature, *args
      end
    end
  end
end

