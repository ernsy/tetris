defmodule Tetris.Main do
  @moduledoc """
  Main module for the DRW Tetris coding challenge. This module contains the algorithm and is also
  used to create the escript that enables the program to be run from the command line.
  """

  @doc """
  Used as an entry point for the escript.
  """
  def main(_args) do
    IO.stream(:stdio, :line)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(&run_game/1)
    |> Stream.map(&(&1.grid_row_max + 1))
    |> Enum.map(&IO.puts/1)
  end

  @doc """
  Runs the tetris game for a list of strings which specify the shape and column.
  The output is the Tetris.Game struct with the value that we're most interested in being the :grid_row_max field.
  Note that this values starts from 0.

  ## Examples
      iex> game = Tetris.Main.run_game(["Q0"])
      iex> game.grid_row_max === 1

      iex> game = Tetris.Main.run_game(["Q0", "Q1"])
      iex> game.grid_row_max === 3
  """
  def run_game(entries) do
    shapes = Enum.map(entries, &parse_entry/1)
    process_shapes(Tetris.Game.new_game(), shapes)
  end

  def process_shapes(game, []) do
    game
  end

  def process_shapes(game, [shape_and_col | rem_shapes]) do
    game
    |> find_row_to_place_shape(shape_and_col)
    |> place_shape(shape_and_col)
    |> remove_completed_rows()
    |> process_shapes(rem_shapes)
  end

  defp parse_entry(entry) do
    # Allows for easy extension of max col size
    {shape, col} = String.next_codepoint(entry)
    {Tetris.Shape.new(shape), String.to_integer(col)}
  end

  defp find_row_to_place_shape(game, {shape, grid_x}) do
    place_shape_y =
      Stream.with_index(shape.offsets)
      |> Enum.map(fn {offset_y, shape_x} ->
        find_lock_row_per_col(game, grid_x, {offset_y, shape_x})
      end)
      |> Enum.max()
      
    %{game | place_shape_row: place_shape_y}
  end

  defp find_lock_row_per_col(game, grid_x, {offset_y, shape_x}) do
    # TODO implement cache of height per column
    grid_y_start = max((game.height_per_col[grid_x + shape_x] || 0) - 1, 0)
    grid_y_min = grid_y_start + offset_y
    grid_y_max = max(game.grid_row_max + 1, grid_y_min)

    Enum.reduce_while(grid_y_min..grid_y_max, grid_y_min, fn grid_y, _ ->
      if game.grid[{grid_x + shape_x, grid_y}] do
        {:cont, grid_y - offset_y}
      else
        {:halt, grid_y - offset_y}
      end
    end)
  end

  defp place_shape(game, {shape, grid_x}) do
    place_shape_y = game.place_shape_row
    grid_row_max_for_shape = place_shape_y + shape.height - 1

    Enum.with_index(grid_x..(grid_x + shape.width - 1))
    |> Enum.reduce(game, fn {x, shape_x}, game ->
      Enum.with_index(place_shape_y..grid_row_max_for_shape)
      |> Enum.reduce(game, fn {y, shape_y}, game ->
        shape_block? = Enum.reverse(shape.coordinates) |> Enum.at(shape_y) |> Enum.at(shape_x)

        if shape_block? do
          grid = Map.put(game.grid, {x, y}, true)
          height_per_col = Map.put(game.height_per_col, x, y + 1)
          %{game | grid: grid, height_per_col: height_per_col}
        else
          game
        end
      end)
    end)
    |> Map.put(:grid_row_max, max(game.grid_row_max, grid_row_max_for_shape))
  end

  defp remove_completed_rows(game) do
    Enum.reduce(0..game.grid_row_max, %{game | rows_removed: 0}, fn y, game ->
      blocks_in_row = count_blocks_in_row(game, y)
      rows_removed = game.rows_removed

      if blocks_in_row == 10 do
        shift_next_row_down(%{game | rows_removed: rows_removed + 1}, y)
      else
        shift_next_row_down(game, y)
      end
    end)
    |> clear_shifted_rows()
  end

  defp count_blocks_in_row(game, y) do
    Enum.reduce(0..game.grid_col_max, 0, fn x, blocks_in_row ->
      if game.grid[{x, y}], do: blocks_in_row + 1, else: blocks_in_row
    end)
  end

  defp shift_next_row_down(%Tetris.Game{rows_removed: rows_removed} = game, _y)
       when rows_removed == 0,
       do: game

  defp shift_next_row_down(%Tetris.Game{rows_removed: rows_removed} = game, y) do
    grid =
      Enum.reduce(0..game.grid_col_max, game.grid, fn x, grid ->
        Map.put(grid, {x, y - rows_removed + 1}, grid[{x, y + 1}])
      end)

    %{game | grid: grid}
  end

  defp clear_shifted_rows(%Tetris.Game{rows_removed: rows_removed} = game)
       when rows_removed == 0,
       do: game

  defp clear_shifted_rows(%Tetris.Game{rows_removed: rows_removed} = game) do
    Enum.reduce(0..game.grid_col_max, game, fn x, game ->
      game = update_height_per_col(game, x)

      Enum.reduce((game.grid_row_max - rows_removed + 1)..game.grid_row_max, game, fn y, game ->
        %{game | grid: Map.drop(game.grid, [{x, y}])}
      end)
    end)
    |> Map.put(:grid_row_max, game.grid_row_max - rows_removed)
  end

  defp update_height_per_col(game, x) do
    height_per_col =
      Enum.reduce_while(
        (game.grid_row_max - game.rows_removed)..0,
        %{game.height_per_col | x => 0},
        fn y, height_per_col ->
          if game.grid[{x, y}] do
            {:halt, %{height_per_col | x => y + 1}}
          else
            {:cont, height_per_col}
          end
        end
      )

    %{game | height_per_col: height_per_col}
  end
end
