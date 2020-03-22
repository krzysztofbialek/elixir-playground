defmodule HarmoImport.CLI do
  def main(args) do
    args 
    |> parse_args
    |> process
  end

  def parse_args(args) do
    parse = OptionParser.parse(args, switches: [ file: :string ],
                                     aliases:  [ f:    :file    ])
  
    case parse do
      { [file: file], _, _ } 
        -> file
      _ ->
        IO.puts """
          file must be present
        """

        System.halt(0)
    end
  end

  def process(file)) do
    login()
    |> importLog(file)
  end

  defp login() do
  end

  defp importLog(file) do
  end
    
end
