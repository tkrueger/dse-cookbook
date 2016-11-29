require 'spec_helper'

# by default we will test with ubuntu 14.04
RSpec.configure do |config|
  config.platform = 'ubuntu'
  config.version = '14.04'
end

describe 'cassandra-env.sh memory settings' do

  def run_chef_with_memory_settings(&additional_configuration)
    ChefSpec::SoloRunner.new do |node|
      node.override['hadoop']['max_heap_size'] = '4g'
      node.override['hadoop']['heap_newsize'] = '2g'
      node.override['solr']['max_heap_size'] = '2g'
      node.override['solr']['heap_newsize'] = '1g'
      node.override['cassandra']['max_heap_size'] = '1024m'
      node.override['cassandra']['heap_newsize'] = '512m'
      additional_configuration.call(node) unless additional_configuration.nil?
    end.converge('dse::cassandra')


  end

  %w{ 4.7 5.0.3-1 }.each do |dse_version|

    context "for dse version #{dse_version}" do
      let(:chef_run) do
        run_chef_with_memory_settings do |node|
          node.override['cassandra']['dse_version'] = dse_version
        end
      end

      it 'contains cassandra value for heap_newsize' do
        expect(chef_run).to render_file('/etc/dse/cassandra/cassandra-env.sh').with_content { |content|
          expect(content).to include('MAX_HEAP_SIZE="1024m"')
          expect(content).to include('HEAP_NEWSIZE="512m"')
        }
      end

      context 'when solr active' do
        let(:chef_run) do
          run_chef_with_memory_settings do |node|
            node.override['cassandra']['dse_version'] = dse_version
            node.override['cassandra']['solr'] = true
          end
        end

        it 'contains solr heapsize values' do
          expect(chef_run).to render_file('/etc/dse/cassandra/cassandra-env.sh').with_content { |content|
            expect(content).to include('MAX_HEAP_SIZE="2g"')
            expect(content).to include('HEAP_NEWSIZE="1g"')
          }
        end
      end

      context 'when hadoop active' do
        let(:chef_run) do
          run_chef_with_memory_settings do |node|
            node.override['cassandra']['dse_version'] = dse_version
            node.override['cassandra']['hadoop'] = true
          end
        end

        it 'contains hadoop heapsize values' do
          expect(chef_run).to render_file('/etc/dse/cassandra/cassandra-env.sh').with_content { |content|
            expect(content).to include('MAX_HEAP_SIZE="4g"')
            expect(content).to include('HEAP_NEWSIZE="2g"')
          }
        end
      end

      context 'when both hadoop and solr active' do
        let(:chef_run) do
          run_chef_with_memory_settings do |node|
            node.override['cassandra']['dse_version'] = dse_version
            node.override['cassandra']['solr'] = true
            node.override['cassandra']['hadoop'] = true
          end
        end

        it 'contains solr heapsize values' do
          expect(chef_run).to render_file('/etc/dse/cassandra/cassandra-env.sh').with_content { |content|
            expect(content).to include('MAX_HEAP_SIZE="2g"')
            expect(content).to include('HEAP_NEWSIZE="1g"')
          }
        end
      end
    end
  end
end
