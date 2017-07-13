require 'spec_helper'

# by default we will test with ubuntu 14.04
RSpec.configure do |config|
  config.platform = 'ubuntu'
  config.version = '14.04'
end

def run_chef(version, &additional_configuration)
  cached(:chef_run) do
    ChefSpec::ServerRunner.new do |node|
      node.override['cassandra']['dse_version'] = version
      yield node unless additional_configuration.nil?
    end.converge('dse')
  end
end

describe 'cassandra.yaml' do
  # have to re-test for every version that does not just link the template to the previous one
  versions_to_test = %w(5.0.0-1 5.0.4-1 5.1.1-1)

  versions_to_test.each do |version|
    context "for version #{version}" do
      context 'with default settings' do
        run_chef version

        it 'will be rendered' do
          expect(chef_run).to create_template('/etc/dse/cassandra/cassandra.yaml').with(
            source: "cassandra_yaml/cassandra_#{version}.yaml.erb",
            owner: 'cassandra',
            group: 'cassandra'
          )
        end
      end

      context 'when memtable_heap_space_in_mb is set' do
        run_chef(version) { |node| node.override['cassandra']['memtable_heap_space_in_mb'] = 123 }

        it 'will render setting' do
          expect(chef_run).to render_file('/etc/dse/cassandra/cassandra.yaml').with_content(include('memtable_heap_space_in_mb: 123'))
        end
      end

      context 'when memtable_offheap_space_in_mb is set' do
        run_chef(version) { |node| node.override['cassandra']['memtable_offheap_space_in_mb'] = 124 }

        it 'will render setting' do
          expect(chef_run).to render_file('/etc/dse/cassandra/cassandra.yaml').with_content(include('memtable_offheap_space_in_mb: 124'))
        end
      end
    end
  end
end
