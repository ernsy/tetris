defmodule Tetris.Main do
  @moduledoc """
  Documentation for `Tetris`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Tetris.hello()
      :world

  """
  def main(_args) do
    stdio = IO.stream(:stdio, :line)
    stdio
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(&IO.inspect/1)
    |> Enum.map(&run_game/1)
    |> IO.inspect()
  end

  def run_game(entries) do
    shapes = Enum.map(entries, &parse_entry/1)
    process_shapes(%Tetris.Game{}, shapes)
    #|> IO.inspect()
    #|> get_max_height()
    :ok
  end

  defp print_grid(game) do
    grid_list =
      for y <- 0..game.grid_row_max, do: for  x <- 0..game.grid_col_max, do: game.grid[{x, y}] && 1 || 0
    IO.inspect(Enum.reverse(grid_list))
    game
  end

  defp parse_entry(entry)   do
    {shape, col} = String.next_codepoint(entry) # Allows for easy extension of max col size
    {Tetris.Shape.new(shape), String.to_integer(col)}
  end

  defp process_shapes(game, []) do
    game
  end
  defp process_shapes(game, [shape_and_col | rem_shapes]) do
    get_row_to_place_shape(game, shape_and_col)
    |> place_shape(shape_and_col)
    |> print_grid
    |> remove_completed_rows
    |> print_grid
      #|> update_height_per_col
    |> process_shapes(rem_shapes)
  end

  defp get_row_to_place_shape(game, {shape, grid_x}) do
    place_shape_y = Stream.with_index(shape.offsets)
                    |> Stream.map(
                         fn ({offset_y, shape_x}) ->
                           grid_y_start = 0 #TODO implement cache of height per column
                           grid_y_min = grid_y_start + offset_y
                           grid_y_max = max(game.grid_row_max + 1, grid_y_min)
                           Enum.reduce_while(
                             grid_y_min..grid_y_max,
                             grid_y_min,
                             fn (grid_y, _) ->
                               if game.grid[{grid_x + shape_x, grid_y}] do
                                 {:cont, grid_y - offset_y}
                               else
                                 {:halt, grid_y - offset_y}
                               end
                             end
                           )
                         end
                       )
                    |> Enum.max()
    %{game | place_shape_row: place_shape_y}
  end

  defp place_shape(game, {shape, grid_x}) do
    place_shape_y = game.place_shape_row
    grid_row_max_for_shape = shape.height + place_shape_y - 1
    grid = Enum.with_index(grid_x..shape.width + grid_x - 1)
           |> Enum.reduce(
                game.grid,
                fn ({x, shape_x}, outer_grid)
                ->
                  Enum.with_index(place_shape_y..grid_row_max_for_shape)
                  |> Enum.reduce(
                       outer_grid,
                       fn ({y, shape_y}, inner_grid) ->
                         shape_block? =
                           Enum.reverse(shape.coordinates)
                           |> Enum.at(shape_y)
                           |> Enum.at(shape_x)
                         shape_block? && Map.put(inner_grid, {x, y}, true) || inner_grid
                       end
                     )
                end
              )
    %{game | grid: grid, grid_row_max: max(game.grid_row_max, grid_row_max_for_shape)}
  end

  defp remove_completed_rows(game) do
    {new_grid, _} = Enum.reduce(
      0..game.grid_row_max,
      {game.grid, 0},
      fn (y, {grid, rows_removed}) ->
        blocks_in_row = count_blocks_in_row(game, y)
        if blocks_in_row == 10 do
          {shift_next_row_down(grid, game.grid_col_max, y, rows_removed), rows_removed + 1}
        else
          {grid, rows_removed}
        end
      end
    )
    %{game | grid: new_grid}
  end

  defp count_blocks_in_row(game, y) do
    Enum.reduce(
      0..game.grid_col_max,
      0,
      fn (x, blocks_in_row) ->
        if game.grid[{x, y}] do
          blocks_in_row + 1
        else
          blocks_in_row
        end
      end
    )
  end

  defp shift_next_row_down(start_grid, max_cols, y, rows_removed) do
    Enum.reduce(
      0..max_cols,
      start_grid,
      fn (x, grid) ->
        Map.put(grid, {x, y - rows_removed + 1}, grid[{x, y + 1}])
      end
    )
  end
  #defp remove_completed_rows(game)  do
  #  {first_row_complete, nr_rows_complete} =
  #    Stream.map(
  #      0..game.grid_row_max,
  #      fn (y) ->
  #        {Enum.all?(0..game.grid_col_max, fn (x) -> game.grid[{x, y}]end), y}
  #      end
  #    )
  #    |> Enum.reduce(
  #         {nil, 0},
  #         fn
  #           ({true, row_y}, {first_row_complete, nr_rows_complete}) ->
  #             {first_row_complete || row_y, nr_rows_complete + 1}
  #           ({row_complete?, row_y}, {first_row_complete, nr_rows_complete}) ->
  #             {first_row_complete, nr_rows_complete}
  #         end
  #       )
  #
  #  game
  #end



  #defp update_height_fields(%Tetris.Game{grid: grid, height_per_col: height_per_col} = game, {shape, col}) do
  #  shape_offset = Tetris.ShapeData.get_shape_offset(shape)
  #  shape_col_height =
  #    Enum.reduce(
  #      shape_offset, {col, 0, height_per_col},
  #      fn ({block_present?, shape_max_height}, {curr_col, h_to_insert_shape, h_per_col}) ->
  #        curr_col_height = h_per_col[col] || 0
  #        lock_shape? = curr_col_height + 1 > h_to_insert_shape
  #        if block_present? && lock_shape? do
  #          {curr_col + 1, curr_col_height + 1, %{h_per_col | col => curr_col_height + shape_max_height}}
  #        else
  #          curr_col_height
  #        end
  #      end
  #    )
  #    |> Enum.max()
  #  %{game | shape_col_height: shape_col_height}
  #end

end
