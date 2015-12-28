require 'aws/tool/ami/version'

require 'thor'

require 'aws/tool/ami/ami_opsworks'

module Aws
  module Tool
    module Ami
      class CLI < Thor

        desc 'create_ami [STACK_NAME]', 'Create AMI of instances which belongs to specified stack'
        option :access_key_id
        option :secret_access_key
        def create_ami(stack_name)

          tool = AmiOpsworks.new(options[:access_key_id], options[:secret_access_key])
          tool.backup_ami(stack_name)

        end

        desc 'scavenge_ami [STACK_NAME]', 'Scavenge outdated AMIs which belongs to specified stack'
        option :access_key_id
        option :secret_access_key
        def scavenge_ami(stack_name)

          tool = AmiOpsworks.new(options[:access_key_id], options[:secret_access_key])
          tool.scavenge_amis(stack_name, remain_days_to_scavenge = 7)

        end

      end
    end
  end
end
