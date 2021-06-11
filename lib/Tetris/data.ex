defmodule Tetris.Game do
  defstruct [grid: %{}, height_per_col: %{}, grid_col_max: 9, grid_row_max: 0, place_shape_row: 0]
end

defmodule Tetris.Shape do
  @moduledoc """
  """
  @type shape_offset :: %{shape :: String.t() => [first_block_offset :: integer]}
  @shape_offsets %{
    "Q" => [0, 0],
    "Z" => [1, 0, 0],
    "S" => [0, 0, 1],
    "T" => [1, 0, 1],
    "I" => [0, 0, 0, 0],
    "L" => [0, 0],
    "J" => [0, 0]
  }

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
    ],
  }

  defstruct [:coordinates, :offsets, :height, :width]

  @spec new(shape :: String.t()) :: struct
  def new(shape) do
    %Tetris.Shape{
      coordinates: @shape_coordinates[shape],
      offsets: @shape_offsets[shape],
      height: length(@shape_coordinates[shape]),
      width: List.first(@shape_coordinates[shape])
             |> length()
    }
  end
end