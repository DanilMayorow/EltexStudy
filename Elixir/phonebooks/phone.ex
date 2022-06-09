defmodule Phone do
  @moduledoc """
  The main function IOPh.main() first starts the process of reading data from the "phones.csv" file:
  read_lines/1 -> parse/1 -> phonebook/1

  If the file is not found, then the process of working with the phonebook/1 phone directory is started with an empty list []
  For a description of the program, see the description of the function phonebook/1
  """

  def main do
    case read_lines("phones.csv") do
      {:ok, out} ->
        IO.inspect out, label: "Data readed"
        base = parse(out, Map.new())
        IO.inspect(base, label: "Data added") |> phonebook()

      _ ->
        phonebook([])
    end
  end

  @doc """
  The private function phonebook/1 is a recursive command request function
   add   - adding a user
   show  - show the current phonebook
   del   - delete user by phone number
   exit  - exit from the program
  """
  @spec phonebook(List.t()) :: List.t()
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

  defp parse([], map), do:  map
  defp parse([h | t], map) do
    [name, age, number] = String.split(h, ";")
    new_map = Map.put(map, number, [name, age])
    parse(t, new_map)
  end

  @doc """
  Private function add_user/1 for adding a user to the phone book
   1. Accepts the old version of the database as input
   2. Asks what data to enter in the format "% Name % Age % Phone Number"
   3. Brings the data to the correct form and adds to the beginning of the phone book list
  """
  @spec add_user(Map.t()) :: Map.t()
  defp add_user(base) do
    input = IO.gets("Set data in format: \"%Name %Age %Phone_number\" \n")
    [name, age, phone] = String.split(String.trim(input), " ", trim: true)
    Map.put(base, phone, [name, age])
  end

  @doc """
  The private function show/1 is a recursive function for displaying the phone book in the terminal
  """
  @spec show(Map.t()) :: Map.t()
  defp show(base) do
    case map_size(base) do
      0 -> IO.puts "<Phonebook is empty>"
      _ ->
      show(Map.keys(base), base)
    end
  end
  defp show([], _), do: IO.puts "<Phonebook end!>"
  defp show([phone | t], base) do
    [name, age] = Map.get(base, phone)
    IO.puts "Name: #{name} Age: #{age} Number: #{phone}"
    show(t, base)
  end

  @doc """
  Private function del_user/1 for deleting a username from the phone book
   1. Accepts the old base as input
   2. Asks for which phone number to delete the user
   3. Calls the del_user/2 function with the old version of the base and the phone number to look up
  """
  @spec del_user(Map.t()) :: Map.t()
  defp del_user(base) do
    input = IO.gets("Set %Phone_number to delete:")
    phone = String.trim(input)
    case Map.pop(base, phone, :none) do
      {:none, _} -> base
      {[name, age], new_map} ->
        IO.puts "User with data [Name: #{name} Age: #{age} Number: #{phone}] was deleted"
        new_map
    end
  end

end
