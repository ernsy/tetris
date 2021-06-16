defmodule Tetris.Game do
  @grid_col_max 9
  defstruct grid: %{},
            grid_col_max: @grid_col_max,
            grid_row_max: 0,
            height_per_col: %{},
            place_shape_row: 0,
            rows_removed: 0

  def new_game() do
    %Tetris.Game{height_per_col: Enum.reduce(0..@grid_col_max, %{}, &Map.put(&2, &1, 0))}
  end
end

defmodule Tetris.Shape do
  @moduledoc """
  """
  @shape_coordinates %{
    "Q" => [
      [true, true],
      [true, true]
    ],
    "Z" => [
      [true, true, false],
      [false, true, true]
    ],
    "S" => [
      [false, true, true],
      [true, true, false]
    ],
    "T" => [
      [true, true, true],
      [false, true, false]
    ],
    "I" => [
      [true, true, true, true]
    ],
    "L" => [
      [true, false],
      [true, false],
      [true, true]
    ],
    "J" => [
      [false, true],
      [false, true],
      [true, true]
    ]
  }

  # first_block_offset represents the row in which the first block for the column corresponding to the position in the
  # list will appear
  @type shape_offset :: %{(shape :: String.t()) => [first_block_offset :: integer]}
  @shape_offsets %{
    "Q" => [0, 0],
    "Z" => [1, 0, 0],
    "S" => [0, 0, 1],
    "T" => [1, 0, 1],
    "I" => [0, 0, 0, 0],
    "L" => [0, 0],
    "J" => [0, 0]
  }

  defstruct [:shape, :coordinates, :offsets, :height, :width]

  @spec new(shape :: String.t()) :: struct
  def new(shape) do
    %Tetris.Shape{
      shape: shape,
      coordinates: @shape_coordinates[shape],
      offsets: @shape_offsets[shape],
      height: length(@shape_coordinates[shape]),
      width:
        List.first(@shape_coordinates[shape])
        |> length()
    }
  end
end
