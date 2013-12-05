#
# Author:: Stefano Tortarolo (<stefano.tortarolo@gmail.com>)
# Copyright:: Copyright (c) 2012-2013
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef
  class Knife
    class VcVmShow < Chef::Knife
      include Knife::VcCommon
      include Knife::VcVmCommon

      banner "knife vc vm show VM (options)"

      def run
        $stdout.sync = true

        vm_arg = @name_args.first

        vm = get_vm(vm_arg)

        out_msg("VM Name", vm.name)
        out_msg("OS Name", vm.operating_system)
        out_msg("Status", vm.status)
        out_msg("vApp", vm.vapp_name)

        list = []
        list << ['', '']

        list << ui.color("Number of Virtual CPUs", :bold)
        list << vm.cpu.to_s

        list << ui.color("Memory size (MB)", :bold)
        list << vm.memory.to_s

        list << [ui.color("Disks", :bold), '']

        vm.hard_disks.each do |disk|
          disk.each do |key, value|
            list << key
            list << value.to_s
          end
        end

        list << ['', '', ui.color('Networks', :bold), '']


        network = vm.network
        list << ["Primary connection", network.primary_network_connection_index.to_s]

        connections = network.connections.collect do |network|
          show_vm_connection(network)
        end

        list << connections

        # list << ['', '', ui.color('Guest Customizations', :bold), '']
        # list.flatten!
        # vm[:guest_customizations].each do |k, v|
        #   list << (pretty_symbol(k) || '')
        #   list << (v || '')
        # end
        list.flatten!
        ui.msg ui.list(list, :columns_across, 2)
      end

      def show_vm_connection(network)
        list = []
        name = network[:network]
        name << " (connected)" if network[:is_connected]

        list << ["Network", name]
        list << ["  Index", network[:network_connection_index].to_s]
        list << ["  Mac address", network[:mac_address]]
        list << ["  Ip allocation mode", network[:ip_address_allocation_mode]]
        list << ["  Ip", network[:ip_address]]
        list << ["  Needs customization", ''] if network[:needsCustomization]
        list
      end
    end
  end
end
