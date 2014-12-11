default['cassandra']['dse']['delegated_snitch'] = 'org.apache.cassandra.locator.SimpleSnitch'
default['cassandra']['dse']['snitch']           = 'com.datastax.bdp.snitch.DseDelegateSnitch'
default['cassandra']['dse']['service_name']     =  'dse'
default['cassandra']['dse']['conf_dir']         = '/etc/dse'
default['cassandra']['dse']['repo_user'] = 'user'
default['cassandra']['dse']['repo_pass'] = 'password'
default['cassandra']['dse']['rhel_repo_url'] = "http://#{node['cassandra']['dse']['repo_user']}:#{node['cassandra']['dse']['repo_pass']}@rpm.datastax.com/enterprise"
default['cassandra']['dse']['debian_repo_url'] = "http://#{node['cassandra']['dse']['repo_user']}:#{node['cassandra']['dse']['repo_pass']}@debian.datastax.com/enterprise"
