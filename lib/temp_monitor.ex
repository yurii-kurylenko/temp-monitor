defmodule TempMonitor do

  @default_interval 20000
  @min_interval 500
  @default_threshold 77

  def main(args) do
    args |> parce_args |> run
  end

  def run(options) do
    threshold = Dict.get(options, :threshold, @default_threshold)
    interval = Dict.get(options, :interval, @default_interval)
    temp_pid = spawn_link(TempMonitor.NodeTemp, :await, [])
    IO.puts "TempMonitor started with parameters at #{current_time}"
    IO.puts "Threshold cpu temp: #{threshold}"
    IO.puts "Check interval: #{interval} ms"
    run(temp_pid, threshold, interval)
  end

  def run(temp_pid, threshold, interval) do
    send temp_pid, {:get_temp, self}
    receive do
      {:ok, temp_probe} ->
        new_interval = inspect_result(temp_probe, threshold, interval)
        :timer.sleep(new_interval)
        run(temp_pid, threshold, new_interval)
    end
  end

  ###

  defp parce_args(args)  do
   {options, _, _} = OptionParser.parse(args,
     switches: [threshold: :integer, interval: :integer ]
   )
   options
  end

  defp inspect_result([{_, current} | _ ], threshold, interval) when current > threshold do
    spawn(fn ->
      beep
    end)
    IO.puts "Current cpu temp #{current}, exceeded threshold #{threshold} at #{current_time}"
    reduce_interval(interval)
  end

  defp inspect_result([{_, _} | _ ], _, interval) do
    increase_interval(interval)
  end

  defp reduce_interval(current_interval) when current_interval > @min_interval do
    IO.puts "Timeout reduced to #{current_interval/2}"
    round(current_interval/2)
  end

  defp reduce_interval(_) do
    @min_interval
  end

  defp increase_interval(current_interval) when current_interval < @default_interval  do
    IO.puts "Interval increased to #{current_interval*2}"
    current_interval*2
  end

  defp increase_interval(_)  do
    @default_interval
  end

  defp beep do
    spawn(fn ->
      System.cmd("spkr_beep", ["900", "2"])
    end)
  end

  defp current_time do
    {date, time} = :calendar.local_time
    {h, mn, s} = time
    {y, m, d} = date
    "#{h}:#{mn}:#{s} #{y}-#{m}-#{d}"
  end
end
