require 'aws/tool/ami/version'

require 'thor'

require 'aws/tool/ami_opsworks'

module Aws
  module Tool
    module Ami
      class CLI < Thor

        desc 'create_ami [STACK_NAME]', 'Create AMI of instances which belongs to specified stack'
        option :config, :required => true
        def create_ami(stack_name)

          tool = AmiOpsworks.new(options[:config])
          tool.backup_ami(stack_name)

        end

        desc 'scavenge_ami [STACK_NAME]', 'Scavenge outdated AMIs which belongs to specified stack'
        option :config, :required => true
        def scavenge_ami(stack_name)

          tool = AmiOpsworks.new(options[:config])
          tool.scavenge_amis(stack_name, remain_days_to_scavenge = 7)

        end

      end
    end
  end
end
