defmodule App.Supervisor do
  use Supervisor

  @moduledoc """
  This is a implementation of Supervisor.
  Supervisors are responsible for handler his childrens (restarting when necessary)
  it follows the fault tolerancy arquitecture.
  """

  @doc "Links the supervisor with called module"
  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end

  @doc """
  Starts supervisor using one_for_one strategy 
  see: http://www.erlang.org/doc/man/supervisor.html
  """
  def init([]) do
    children = []
    supervise children, strategy: :one_for_one
  end

end
