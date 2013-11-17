set :output, "/log/cron"
every 1.minutes do
  rake 'load_pulse_energy'
end