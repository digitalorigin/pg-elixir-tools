defmodule ElixirTools.Events.NotSentEvent do
  @moduledoc """
  Schema used for saving not sent (due to a failure) events to DB.
  They supposed to be resend later, after this a field `is_sent` has to be set to `true`
  """

  use ElixirTools.Schema

  alias __MODULE__
  alias Ecto.Changeset

  @type external_reference :: String.t()
  @type t :: %NotSentEvent{
          id: id | nil,
          content: String.t(),
          is_sent: boolean
        }

  @allowed_fields ~w(content is_sent)a
  @required_fields ~w(content is_sent)a

  schema "not_sent_events" do
    field(:content, :string)
    field(:is_sent, :boolean, default: false)

    timestamps()
  end

  @impl true
  def changeset(params) do
    %NotSentEvent{}
    |> Changeset.cast(params, @allowed_fields)
    |> Changeset.validate_required(@required_fields)
  end
end
