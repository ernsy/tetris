defmodule Tetris.MainTest do
  use ExUnit.Case
  doctest Tetris.Main

  test "running games with pre solved examples
  and printing visual representation of the game grid" do
    run_game_test(["Q0", "Q2", "Q4", "Q6", "Q8"], -1)
    run_game_test(["Q0", "Q2", "Q4", "Q6", "Q8", "Q1"], 1)
    run_game_test(["Q0", "Q2", "Q4", "Q6", "Q8", "Q1", "Q1"], 3)
    run_game_test(["I0", "I4", "Q8"], 0)
    run_game_test(["I0", "I4", "Q8", "I0", "I4"], -1)
    run_game_test(["L0", "J2", "L4", "J6", "Q8"], 1)
    run_game_test(["L0", "Z1", "Z3", "Z5", "Z7"], 1)
    run_game_test(["T0", "T3"], 1)
    run_game_test(["T0", "T3", "I6", "I6"], 0)
    run_game_test(["I0", "I6", "S4"], 0)
    run_game_test(["T1", "Z3", "I4"], 3)
    run_game_test(["L0", "J3", "L5", "J8", "T1"], 2)
    run_game_test(["L0", "J3", "L5", "J8", "T1", "T6"], 0)
    run_game_test(["L0", "J3", "L5", "J8", "T1", "T6", "J2", "L6", "T0", "T7"], 1)
    run_game_test(["L0", "J3", "L5", "J8", "T1", "T6", "J2", "L6", "T0", "T7", "Q4"], 0)
    run_game_test(["S0", "S2", "S4", "S6"], 7)
    run_game_test(["S0", "S2", "S4", "S5", "Q8", "Q8", "Q8", "Q8", "T1", "Q1", "I0", "Q4"], 7)
    run_game_test(["L0", "J3", "L5", "J8", "T1", "T6", "S2", "Z5", "T0", "T7"], -1)
    run_game_test(["Q0", "I2", "I6", "I0", "I6", "I6", "Q2", "Q4"], 2)
    run_game_test(["Q6","Z0","I2","Z4","I6","Z0","Q2","L5","J8","T2","L4","L7","Q0","I2","I6","L0","I4"], 9)
  end

  test "running games with random inputs" do
    IO.puts("\n Testing random inputs")
    Enum.map(0..10, fn (_) -> generate_random_inputs(1000) end) |> Enum.each(&(run_game_test/1))
  end

  defp run_game_test(input, output) do
    IO.puts("Test input:\n #{inspect(input)}")
    game = Tetris.Main.run_game(input)
    highest_row = print_grid(game) |> List.first() || []
    if length(highest_row) > 0, do: Enum.any?(highest_row, &(&1 == 1)) |> assert()
    assert(game.grid_row_max === output)
  end

  defp run_game_test(input) do
    IO.puts("Test input:\n #{inspect(input)}")
    game = Tetris.Main.run_game(input)
    print_grid(game) |> List.first() |> Enum.any?(&(&1 == 1)) |> assert()
  end

  defp print_grid(game) do
    IO.puts("Game grid:")

    if game.grid_row_max > -1 do
      for y <- game.grid_row_max..0 do
        for x <- 0..game.grid_col_max do
          if game.grid[{x, y}], do: 1, else: 0
        end
        |> IO.inspect()
      end
    else
      []
    end
  end

  defp generate_random_inputs(nr_shapes) do
    Stream.repeatedly(fn ->
      shape = Enum.random(["Q", "Z", "S", "T", "L", "J"])

      max_col_offset =
        cond do
          Enum.member?(["Q", "L", "J"], shape) -> 2
          Enum.member?(["Z", "S", "T"], shape) -> 3
          shape == "I" -> 4
        end

      shape <> to_string(Enum.random(0..(10 - max_col_offset)))
    end)
    |> Enum.take(Enum.random(1..nr_shapes))
  end
end
