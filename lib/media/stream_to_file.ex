defmodule Media.StreamToFile do
  use Membrane.Pipeline

  alias Membrane.{File, FFmpeg, MP3.MAD, MP3.Lame, PortAudio, Time}
  alias Membrane.Element.Tee
  alias Membrane.Caps.Audio.Raw
  alias Membrane.Audiometer.Peakmeter

  @impl true
  def handle_init(output_directory) do
    Elixir.File.mkdir_p!(output_directory)

    children = [
      file_input: %File.Source{location: "sample.mp3"},
      decoder: MAD.Decoder,
      meter: %Peakmeter{interval: Membrane.Time.milliseconds(1000)},
      #converter: %FFmpeg.SWResample.Converter{
      #  input_caps: %Raw{channels: 2, format: :s24le, sample_rate: 44_100},
      #  output_caps: %Raw{channels: 2, format: :s32le, sample_rate: 44_100}
      #},
      #splitter: Tee.Master,
      #encoder: Lame.Encoder,
      raw_output: %File.Sink{location: Path.join(output_directory, "out.raw")},
      #encoded_output: %File.Sink{location: Path.join(output_directory, "out.mp3")}
    ]

    links = [
      link(:file_input) |> to(:decoder) |> to(:meter) |> to(:raw_output),
      #link(:splitter) |> via_out(:master) |> to(:raw_output),
      #link(:splitter) |> via_out(:copy) |> to(:encoder) |> to(:encoded_output)
    ]

    {{:ok, spec: %ParentSpec{children: children, links: links}}, %{}}
  end

  @impl true
  def handle_notification({:amplitudes, [ch1, ch2]}, element, context, state) do
    IO.inspect({ch1, context.clock}, label: "amp")
    {:ok, state}
  end

  def handle_notification(any, element, context, state) do
    IO.inspect(any, label: "any")
    {:ok, state}
  end


end
