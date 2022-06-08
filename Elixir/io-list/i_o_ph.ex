defmodule IOPh do
  @moduledoc """
  Documentation for `IOPh`.
  """

  def main do
    case read_lines("phones.csv") do
      {:ok, out} ->
      IO.inspect out, label: "Data readed"
      base = parse(out)
      IO.inspect(base, label: "Data added") |> phonebook()
      
      _ ->
      phonebook([])
    end
  end

  defp phonebook(old_base) do
    input = IO.gets("Choose operation(add,show,del,exit): ")
    com = String.trim(input)
    option = String.to_atom(com)
    new_base =  case option do
      :add -> add_user(old_base)
      :show ->
        show(old_base)
        old_base
      :del -> del_user(old_base)
      :exit -> System.halt(0)
      _ -> old_base
    end
    phonebook(new_base)
  end

  defp read_lines(file_name) do
    case File.read(file_name) do
      {:ok, data} ->
        res = String.split(data,"\r\n", trim: true)
        {:ok, res}
      {result, reason} ->
        IO.puts "File doesn't exported! \nResult: #{result} Info: #{reason} \n"
        :error
    end
  end

  defp parse([]), do:  []
  defp parse([h | t]) do
    [name, age, number] = String.split(h, ";")
    [{name, age, number} | parse(t)]
  end

  defp add_user(base) do
    input = IO.gets("Set data in format: \"%Name %Age %Phone_number\" \n")
    [name, age, phone] = String.split(String.trim(input), " ", trim: true)
    [{name,age,phone}|base]
  end

  defp show([]), do: []
  defp show([{name, age, number} | t]) do
    IO.puts "Name: #{name} Age: #{age} Number: #{number}"
    show(t)
  end

  defp del_user(base) do
    input = IO.gets("Set %Phone_number to delete:")
    phone = String.trim(input)
    del_user(base,phone)
  end

  defp del_user([], _) do [] end
  defp del_user([h | t], user) when h == user, do: t
  defp del_user([h | t], user), do: [h | del_user(t, user)]

end
