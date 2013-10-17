require "../types"
require "../llvm"

module Crystal
  class LLVMTyper
    def initialize
      @cache = {} of Type => LLVM::Type
      @struct_cache = {} of Type => LLVM::Type
    end

    def llvm_type(type)
      @cache[type] ||= create_llvm_type(type)
    end

    def create_llvm_type(type : PrimitiveType)
      type.llvm_type
    end

    def create_llvm_type(type : InstanceVarContainer)
      LLVM::PointerType.new(llvm_struct_type(type))
    end

    def create_llvm_type(type : Metaclass)
      LLVM::Int64
    end

    def create_llvm_type(type : GenericClassInstanceMetaclass)
      LLVM::Int64
    end

    def create_llvm_type(type : PointerInstanceType)
      pointed_type = llvm_embedded_type type.var.type
      pointed_type = LLVM::Int8 if pointed_type == LLVM::Void
      LLVM::PointerType.new(pointed_type)
    end

    def create_llvm_type(type : UnionType)
      llvm_value_type = LLVM::ArrayType.new(LLVM::Int32, 4) #type.llvm_value_size.fdiv(LLVM::Int.type.width / 8).ceil)
      LLVM::StructType.new(type.llvm_name, [LLVM::Int32, llvm_value_type])
    end

    def create_llvm_type(type)
      raise "Bug: called create_llvm_type for #{type}"
    end

    def llvm_struct_type(type)
      @struct_cache[type] ||= create_llvm_struct_type(type)
    end

    def create_llvm_struct_type(type : InstanceVarContainer)
      @struct_cache[type] ||= begin
        struct = LLVM::StructType.new type.llvm_name

        ivars = type.all_instance_vars.values
        element_types = Array(LLVM::Type).new(ivars.length)
        ivars.each { |ivar| element_types.push llvm_embedded_type(ivar.type) }

        struct.element_types = element_types
        struct
      end
    end

    def create_llvm_struct_type(type)
      raise "Bug: called llvm_struct_type for #{type}"
    end

    def llvm_arg_type(type)
      llvm_type type
    end

    def llvm_embedded_type(type)
      llvm_type type
    end
  end
end
