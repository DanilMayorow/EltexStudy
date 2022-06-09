defmodule Recur do
  @moduledoc """
  Module of practical tasks for writing recursive functions:
  Pow-function
  Factorial calculating function
  Ackermann-function
  Factorization function
  """

  @doc """
  Show test results for:
  Pow-function
  Factorial calculating function
  Ackermann-function
  Factorization function

  ###By default execute function at 10 times
  """
  def main do
    tpw = test(:pow, [1024, 1024], 10)
    IO.inspect [tpw, {:avg, Enum.sum(tpw)/10}], label: "Pow-func"
    tfq = test(:fact,[1024], 10)
    IO.inspect [tfq, {:avg, Enum.sum(tfq)/10}], label: "Factorial"
    tak = test(:aker,[4,1], 10)
    IO.inspect [tak, {:avg, Enum.sum(tak)/10}], label: "Ackermann-func"
    tnd = test(:ndiv,[720720], 10)
    IO.inspect [tnd, {:avg, Enum.sum(tnd)/10}], label: "Factorization"
    :ok
  end

  @doc """
  Test function: accept function, arguments and number of runs
  """
  @spec test(Function.t(), [number()], Integer.t(), [number()]) :: number()
  def test(fun, arg, num, acc \\ [])
  def test(_, _, 0, acc), do: acc
  def test(fun, arg, num, acc) do
    {time,_} = :timer.tc(Recur, fun, arg)
    test(fun, arg, num-1, [time|acc])
  end

  @doc """
  Exponentiation function
  """
  @spec pow(Integer.t(), Integer.t()) :: Integer.t() | Float.t()
  def pow(_, 0), do: 1
  def pow(x, n) when n < 0, do: (1/x)*pow(x, n+1)
  def pow(x, n), do: x*pow(x, n-1)

  @doc """
  Factorial calculating function
  """
  @spec fact(Integer.t()) :: Integer.t()
  def fact(x), do: fact(x, 1)
  defp fact(0, acc), do: acc
  defp fact(x, acc), do: fact(x-1, acc*x)

  @doc """
  Ackermann function
  """
  @spec aker(Integer.t(), Integer.t()) :: Integer.t()
  def aker(m, n) when m < 0 and n < 0, do: :error
  def aker(0, n), do: n+1
  def aker(m, 0), do: aker(m-1, 1)
  def aker(m, n), do: aker(m-1, aker(m, n-1))

  @doc """
  Function sum of digits in number
  """
  @spec nsum(Integer.t()) :: Integer.t()
  def nsum(n) do
    case div(n, 10) do
      0 -> n
      rest -> rem(n,10) + nsum(rest)
    end
  end

  @doc """
  The function of splitting a number into prime factors in ascending order
  """
  @spec ndiv(Ineger.t()) :: Integer.t()
  def ndiv(n) do
    ndiv(n, 2)
    IO.write "\n"
  end
  defp ndiv(n, k) do
    if k > div(n,2) do
      IO.write "#{n} "
    else
      case rem(n, k) do
        0 ->
          IO.write "#{k "
          ndiv(div(n, k), k)
        _ -> ndiv(n, k+1)
      end
    end
  end
end
