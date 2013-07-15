require 'yaml'

#
# Cookbook: nrsysmond
# Configures /etc/newrelic/nrsysmond.cfg. nrsysmond should already be installed by Engine Yard Cloud.
#

# Get the license key that Engine Yard will already have on the instance(s)
key = YAML.load_file("/data/#{node[:applications].first.first}/shared/config/ey_services_config_deploy.yml")["New Relic"]["license_key"]

# Spit out the template
template "/etc/newrelic/nrsysmond.cfg" do
  source "nrsysmond.cfg.erb"
  owner "root"
  group "root"
  mode 0644
  variables({
    license_key: key
  })
end

# Restart nrsysmond
execute "restart nrsysmond" do
  command "sudo /etc/init.d/newrelic-sysmond restart" # apparently monit can't take commands "too fast". How lame.
end