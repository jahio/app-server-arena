##
# Cookbook: puma
# Reconfigures puma to run through sockets instead of ports. Must already have puma installed.
#

# Don't run this on any environment that isn't the one it's SUPPOSED to be.
if node[:environment][:name] == 'asa_puma'
  ey_cloud_report "puma" do
    message "Reconfiguring puma to run on sockets..."
  end

  cpu_count = get_cpu_count

  node[:applications].each do |app_name, data|
    template "/data/#{app_name}/shared/config/#{app_name}_puma_control" do
      source "puma_control.erb"
      owner node[:owner_name]
      group node[:owner_name]
      mode 0554 # owner: r/x, group: r/x, others: r
      variables({
        num_workers: cpu_count, # since puma is threaded we don't need more than num_cores, generally (GVL withstanding)
        app_name: app_name
      })
    end

    template "/etc/monit.d/puma.#{app_name}.monitrc" do
      source "monitrc.erb"
      owner node[:owner_name]
      group node[:owner_name]
      mode 0644
      variables({
        app_name: app_name,
        num_workers: cpu_count
      })
    end

    template "/etc/nginx/servers/#{app_name}.conf" do
      source "nginx.conf.erb"
      owner node[:owner_name]
      group node[:owner_name]
      mode 0644
      variables({
        app_name: app_name,
        num_workers: cpu_count
      })
    end

    # Stop Engine Yard's puma processes through monit
    execute "stop EY Puma" do
      command "sudo monit stop all -g #{app_name} && sleep 1"
    end

    # Reload monit and start puma
    execute "reload monit and start puma" do
      command "sudo monit reload && sleep 1 && sudo monit start all -g puma_#{app_name}"
    end
  end

  # Now that that's done, restart nginx with the new configuration
  execute "restart nginx" do
    command "sudo /etc/init.d/nginx restart"
  end
end