defmodule TempMonitor.NodeTemp do

  def check do
     sensors |> format_temp_output
  end

  def await do
    receive do
      {:get_temp, pid } ->
        send pid, {:ok, check}
        await
    end
  end

  defp sensors do
    System.cmd("sensors", [])
  end

  defp format_temp_output({text, _}) do
    Regex.scan(~r/Core\s\d\:\s.*/, text)
      |> Enum.map(&extract_temp_probe/1)
  end

  defp extract_temp_probe [raw_string]  do
    extract_regex = ~r/Core\s(\d)\:\s+\+(\d\d\.\d)/
    tl(Regex.run(extract_regex, raw_string))
      |> Enum.map(&(elem(Float.parse(&1), 0)))
      |> List.to_tuple
  end

end
