defmodule ImageProcessor do
  def load(path) do
    {:ok, image} = Imagineer.load(path)
    image
  end

  def chunk(image, options \\ []) do
    # Provide default options
    defaults = [width: 64, height: 64]
    options = Keyword.merge(defaults, options)
    image.pixels |> Util.chunk_2d(options)
  end

  def to_grayscale(pixels) do
    Enum.map pixels, fn
      {r, g, b, _a} -> (r + g + b) / 3
      {r, g, b}     -> (r + g + b) / 3
    end
  end

  def flatten_pixels(pixels) do
    Enum.flat_map pixels, fn
      {r, g, b} -> [r, g, b]
      {r, g, b, a} -> [r, g, b, a]
    end
  end

  def normalize_values(values) do
    Enum.map values, fn value -> value / 255 end
  end
end
