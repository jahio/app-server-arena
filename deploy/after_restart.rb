# Thin doesn't come standard on Engine Yard, so after restart, if this is
# a thin app, shut off unicorn and turn on thin.
if environment_name == 'asa_thin'
  # Start thin ASAP
  run! "/data/#{app}/shared/config/thin_control.sh restart"
    # Will log errors if thin isn't already running but that's no biggie,
    # it'll still launch thin. Will do a rolling restart of workers
    # if chef has properly run.

  # Stop Unicorn
  sudo! "monit stop all -g unicorn_#{app} && sleep 1"

  # Unmonitor Unicorn
  sudo! "monit unmonitor all -g unicorn_#{app}"
end

# If we're on the puma environment...
if environment_name == "asa_puma"
  run! "/data/#{app}/shared/config/puma_control restart"
  sudo! "monit stop all -g #{app} && sleep 1"
  sudo! "monit unmonitor all -g #{app}"
end