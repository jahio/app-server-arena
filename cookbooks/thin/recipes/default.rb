# 
# Cookbook: thin
# Installs the thin app server on the instance and sets up nginx and monit to use it
#

# Don't run this on any environment that isn't the one it's SUPPOSED to be.
if node[:environment][:name] == 'asa_thin'
  ey_cloud_report "thin" do
    message "Installing and configuring thin..."
  end

  # Figure out how many CPU cores are on the machine.
  num_cores = get_cpu_count

  # Now that we know the number of cores, add 1.5 and round for num_workers
  # This is how many application workers we're going to spin up. We do this
  # because it's conceivable that one-per-core may not hit as much throughput
  # for various reasons (iowait, network latency, etc.) as it could, so the
  # remainder is to make up for that slack. This scheme may not work well
  # on machines with really high numbers of CPU cores, or memory that doesn't
  # really "line up" with the number of corese (e.g. 1GB on an 8 core box or
  # something crazy like that) so adjust as needed.
  num_workers = (num_cores * 1.5).round

  node[:applications].each do |app_name, data|
    # Install thin with the appropriate number of workers.
    template "/data/#{app_name}/shared/config/thin.yml" do
      source "thin.yml.erb"
      owner node[:owner_name]
      group node[:owner_name]
      mode 0644
      variables({
        num_workers: num_workers,
        app_name: app_name,
        framework_env: node[:environment][:framework_env],
        user: node[:owner_name]
      })
    end

    template "/etc/monit.d/thin.#{app_name}.monitrc" do
      source "thin.monitrc.erb"
      owner "root"
      group "root"
      mode 0644
      variables({
        app_name: app_name,
        num_workers: num_workers
      })
    end

    template "/data/#{app_name}/shared/config/env.custom" do
      source "env.custom.erb"
      owner node[:owner_name]
      group node[:group_name]
      mode 0644
      variables({
        framework_env: node[:environment][:framework_env],
        app_name: app_name
      })
    end

    template "/data/#{app_name}/shared/config/thin_control.sh" do
      source "thin_control.sh.erb"
      owner node[:owner_name]
      group node[:owner_name]
      mode 0554 # owner: r/x, group: r/x, others: r
      variables({
        app_name: app_name        
      })
    end

    template "/etc/nginx/servers/#{app_name}.conf" do
      source "nginx.conf.erb"
      owner node[:owner_name]
      group node[:owner_name]
      mode 0644
      variables({
        app_name: app_name,
        vhost: "_", # whatever you set the domain name as in the dashboard
        num_workers: num_workers
      })
    end

    # Now that it's installed, reload monit, shut off Unicorn, and flip the switch on Thin.
    execute "reload_monit" do
      command "sudo monit reload && sleep 1" # apparently monit can't take commands "too fast". How lame.
    end

    execute "shut_down_unicorn" do
      command "sudo monit stop all -g unicorn_#{app_name} && sleep 1"
    end

    execute "unmonitor_unicorn" do
      command "sudo monit unmonitor all -g unicorn_#{app_name} && sleep 1"
    end

    execute "start_thin" do
      command "sudo monit start all -g thin_#{app_name}"
    end
  end

  # Restart nginx.
  execute "restart_nginx" do
    command "sudo /etc/init.d/nginx restart"
  end

end