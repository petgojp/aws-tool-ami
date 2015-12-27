require 'aws/tool/ami/version'

require 'thor'

require 'aws/tool/ami_opsworks'

module Aws
  module Tool
    module Ami
      class CLI < Thor

        desc 'create_ami [STACK_NAME]', 'Create AMI of instances which belongs to specified stack'
        def create_ami(stack_name)

          ami = AmiOpsworks.new('config.json')
          ami.backup_ami(stack_name)

        end

        desc 'scavenge_ami [STACK_NAME]', 'Scavenge outdated AMIs which belongs to specified stack'
        def scavenge_ami(stack_name)

          ami = AmiOpsworks.new('config.json')
          ami.scavenge_amis(stack_name, remain_days_to_scavenge = 7)

        end

      end
    end
  end
end
