defmodule CourseTest do
  use ExUnit.Case
  doctest Course

  test "greets the world" do
    assert Course.hello() == :world
  end
end
