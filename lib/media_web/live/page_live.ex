defmodule MediaWeb.PageLive do
  use MediaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Media.PubSub, "audio")
      Media.ensure_playing()
    end

    {:ok, assign(socket, channels: [])}
  end

  def handle_info({:amplitudes, channels}, socket) do
    channels =
      Enum.map(channels, fn negative_db ->
        case negative_db do
          :infinity ->
            0

          num ->
            100 - round(num * -1.0)
        end
      end)

    {:noreply, assign(socket, channels: channels)}
  end
end
