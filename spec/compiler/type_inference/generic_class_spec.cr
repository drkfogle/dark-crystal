require "../../spec_helper"

describe "Type inference: generic class" do
  it "errors if inheriting from generic when it is non-generic" do
    assert_error %(
      class Foo
      end

      class Bar < Foo(T)
      end
      ),
      "Foo is not a generic class, it's a class"
  end

  it "errors if inheriting from generic and incorrect number of type vars" do
    assert_error %(
      class Foo(T)
      end

      class Bar < Foo(A, B)
      end
      ),
      "wrong number of type vars for Foo(T) (2 for 1)"
  end

  it "inhertis from generic with instantiation" do
    assert_type(%(
      class Foo(T)
        def t
          T
        end
      end

      class Bar < Foo(Int32)
      end

      Bar.new.t
      )) { int32.metaclass }
  end

  it "inhertis from generic with forwarding (1)" do
    assert_type(%(
      class Foo(T)
        def t
          T
        end
      end

      class Bar(U) < Foo(U)
      end

      Bar(Int32).new.t
      )) { int32.metaclass }
  end

  it "inhertis from generic with forwarding (2)" do
    assert_type(%(
      class Foo(T)
      end

      class Bar(U) < Foo(U)
        def u
          U
        end
      end

      Bar(Int32).new.u
      )) { int32.metaclass }
  end

  it "inhertis from generic with instantiation with instance var" do
    assert_type(%(
      class Foo(T)
        def initialize(@x : T)
        end

        def x
          @x
        end
      end

      class Bar < Foo(Int32)
      end

      Bar.new(1).x
      )) { int32 }
  end

  it "inherits twice" do
    assert_type(%(
      class Foo
        def initialize
          @x = 1.5
        end

        def x
          @x
        end
      end

      class Bar(T) < Foo
        def initialize(@y : T)
          super()
        end

        def y
          @y
        end
      end

      class Baz < Bar(Int32)
        def initialize(y, @z)
          super(y)
        end

        def z
          @z
        end
      end

      baz = Baz.new(1, 'a')
      baz.y
      )) { int32 }
  end

  it "inherits non-generic to generic (1)" do
    assert_type(%(
      class Foo(T)
        def t1
          T
        end
      end

      class Bar < Foo(Int32)
      end

      class Baz(T) < Bar
      end

      baz = Baz(Float64).new
      baz.t1
      )) { int32.metaclass }
  end

  it "inherits non-generic to generic (2)" do
    assert_type(%(
      class Foo(T)
        def t1
          T
        end
      end

      class Bar < Foo(Int32)
      end

      class Baz(T) < Bar
        def t2
          T
        end
      end

      baz = Baz(Float64).new
      baz.t2
      )) { float64.metaclass }
  end

  it "defines empty initialize on inherited generic class" do
    assert_type(%(
      class Maybe(T)
      end

      class Nothing < Maybe(Int32)
        def initialize
        end
      end

      Nothing.new
      )) { types["Nothing"] }
  end
end
