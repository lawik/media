defmodule Media do
  @moduledoc """
  Media keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def record_to_file(path) do
    {:ok, pid} = Media.StreamToFile.start_link(path)
    Media.StreamToFile.play(pid)
    {:ok, pid}
  end

  def stop_to_file(pid) do
    Media.StreamToFile.stop_and_terminate(pid)
  end
end
