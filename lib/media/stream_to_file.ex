defmodule Media.StreamToFile do
  use Membrane.Pipeline

  alias Membrane.{File, FFmpeg, MP3.MAD, MP3.Lame, PortAudio, Time}
  alias Membrane.Element.Tee
  alias Membrane.Caps.Audio.Raw

  @impl true
  def handle_init(output_directory) do
    Elixir.File.mkdir_p!(output_directory)

    children = [
      mic_input: PortAudio.Source,
      converter: %FFmpeg.SWResample.Converter{
        input_caps: %Raw{channels: 2, format: :s16le, sample_rate: 48_000},
        output_caps: %Raw{channels: 2, format: :s32le, sample_rate: 44_100}
      },
      splitter: Tee.Master,
      encoder: Lame.Encoder,
      raw_output: %File.Sink{location: Path.join(output_directory, "out.raw")},
      encoded_output: %File.Sink{location: Path.join(output_directory, "out.mp3")}
    ]

    links = [
      link(:mic_input) |> to(:converter) |> to(:splitter),
      link(:splitter) |> via_out(:master) |> to(:raw_output),
      link(:splitter) |> via_out(:copy) |> to(:encoder) |> to(:encoded_output)
    ]

    {{:ok, spec: %ParentSpec{children: children, links: links}}, %{}}
  end
end
