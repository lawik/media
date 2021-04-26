defmodule Media.StreamToFile do
  use Membrane.Pipeline

  alias Membrane.{File, PortAudio}
  alias Membrane.Audiometer.Peakmeter

  @impl true
  def handle_init(output_directory) do
    Elixir.File.mkdir_p!(output_directory)
    Process.register(self(), :default_stream)

    children = [
      mic_input: PortAudio.Source,
      audiometer: %Peakmeter{interval: Membrane.Time.milliseconds(50)},
      raw_output: %File.Sink{location: Path.join(output_directory, "out.raw")}
    ]

    links = [
      link(:mic_input) |> to(:audiometer) |> to(:raw_output)
    ]

    {{:ok, spec: %ParentSpec{children: children, links: links}}, %{}}
  end

  @impl true
  def handle_notification({:amplitudes, channels}, _element, _context, state) do
    IO.inspect(channels, label: "amplitude")
    Phoenix.PubSub.broadcast!(Media.PubSub, "audio", {:amplitudes, channels})
    {:ok, state}
  end

  def handle_notification(_any, _element, _context, state) do
    {:ok, state}
  end
end
