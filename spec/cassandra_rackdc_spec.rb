require 'spec_helper'

# by default we will test with ubuntu 14.04
RSpec.configure do |config|
  config.platform = 'ubuntu'
  config.version = '14.04'
end

describe 'cassandra-rackdc.properties' do
  %w(4.7 5.0.4-1).each do |dse_version|
    def run_chef(&additional_configuration)
      ChefSpec::SoloRunner.new do |node|
        yield node unless additional_configuration.nil?
      end.converge('dse::cassandra')
    end

    context "for dse version #{dse_version}" do
      let(:chef_run) do
        run_chef do |node|
          node.override['cassandra']['dse_version'] = dse_version
        end
      end

      it 'does not render /etc/dse/cassandra/cassandra-rackdc.properties' do
        expect(chef_run).not_to render_file('/etc/dse/cassandra/cassandra-rackdc.properties')
      end

      context 'when a snitch is set that needs it' do
        let(:chef_run) do
          run_chef do |node|
            node.override['cassandra']['dse_version'] = dse_version
            node.override['cassandra']['dse']['snitch'] = 'GossipingPropertyFileSnitch'
            node.override['datacenter'] = 'datacenter_name'
          end
        end

        it 'renders /etc/dse/cassandra/cassandra-rackdc.properties' do
          expect(chef_run).to render_file('/etc/dse/cassandra/cassandra-rackdc.properties')
        end

        context "and node['cassandra']['solr']=true" do
          context 'and use_exact_datacenter_name is true' do
            let(:chef_run) do
              run_chef do |node|
                node.override['cassandra']['dse_version'] = dse_version
                node.override['cassandra']['solr'] = true
                node.override['cassandra']['dse']['use_exact_datacenter_name'] = true
                node.override['cassandra']['dse']['snitch'] = 'GossipingPropertyFileSnitch'
                node.override['datacenter'] = 'datacenter_name'
              end
            end

            it 'renders the unchanged datacenter name' do
              expect(chef_run).to render_file('/etc/dse/cassandra/cassandra-rackdc.properties').with_content(include('dc=datacenter_name'))
            end
          end

          context 'and use_exact_datacenter_name is false' do
            let(:chef_run) do
              run_chef do |node|
                node.override['cassandra']['dse_version'] = dse_version
                node.override['cassandra']['solr'] = true
                node.override['cassandra']['dse']['use_exact_datacenter_name'] = false
                node.override['cassandra']['dse']['snitch'] = 'GossipingPropertyFileSnitch'
                node.override['datacenter'] = 'datacenter_name'
              end
            end

            it 'renders the datacenter name with solr-prefix' do
              expect(chef_run).to render_file('/etc/dse/cassandra/cassandra-rackdc.properties').with_content(include('dc=solrdatacenter_name'))
            end
          end
        end

        context 'and solr and hadoop are off' do
          context 'and use_exact_datacenter_name false' do
            let(:chef_run) do
              run_chef do |node|
                node.override['cassandra']['dse_version'] = dse_version
                node.override['cassandra']['solr'] = false
                node.override['cassandra']['solr'] = false
                node.override['cassandra']['dse']['use_exact_datacenter_name'] = true
                node.override['cassandra']['dse']['snitch'] = 'GossipingPropertyFileSnitch'
                node.override['datacenter'] = 'datacenter_name'
              end
            end

            it 'renders the unchanged datacenter name' do
              expect(chef_run).to render_file('/etc/dse/cassandra/cassandra-rackdc.properties').with_content(include('dc=datacenter_name'))
            end
          end
        end
      end
    end
  end
end
