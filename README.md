# TempMonitor

Simple elixir tool which makes beep sound when cpu temperature exceeds threshold.

Currently supports only Ubuntu

# Pre-requirements:
- Erlang
- Elixir
- lm-sensors
- config/spkr_beep.sh link in $PATH

# Build:
mix escript.build

# Parameters
--threshold (threshold of CPU temp in celsius, default 77)
--interval (interval of CPU temp checking in ms, default 20000)

# Example:
./temp_monitor --threshold=80 --interval=10000
