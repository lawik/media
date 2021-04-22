defmodule Media.StreamToFile do
  use Membrane.Pipeline

  alias Membrane.{File, FFmpeg, MP3.MAD, MP3.Lame, PortAudio, Time, Tee}

  @impl true
  def handle_init(output_directory) do
    Elixir.File.mkdir_p!(output_directory)
    children = [
      mic_input: PortAudio.Source,
      splitter: Tee.Master,
      encoder: Lame.Encoder,
      raw_output: %File.Sink{location: Path.join(output_directory, "out.raw")},
      encoded_output: %File.Sink{location: Path.join(output_directory, "out.mp3")},
    ]
    links = [
      link(:mic_input) |> to(:splitter),
      link(:splitter) |> via_out(:master) |> to(:raw_output),
      link(:splitter) |> via_out(:copy) |> to(:encoder) |> to(:encoded_output)
    ]

    {{:ok, spec: %ParentSpec{children: children, links: links}}, %{}}
  end
end
