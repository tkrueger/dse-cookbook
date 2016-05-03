
remote_file "/usr/share/cassandra/#{node['cassandra']['prometheus_metrics']['jar_name']}" do
  source node['cassandra']['prometheus_metrics']['jar_url']
  owner node['cassandra']['user']
  group node['cassandra']['group']
end

template "#{node['cassandra']['dse']['conf_dir']}/cassandra/cassandra-prometheus-metrics.yaml" do
  source 'cassandra-prometheus-metrics.yaml.erb'
  owner node['cassandra']['user']
  group node['cassandra']['group']
  mode 0644
  notifies :restart, "service[#{node['cassandra']['dse']['service_name']}]"
  variables(:yaml_config => hash_to_yaml_string(node['cassandra']['prometheus_metrics']['config']))
end
