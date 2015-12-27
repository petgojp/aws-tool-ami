#!/usr/bin/ruby
require 'rubygems'
require 'aws-sdk'
require 'json'
require 'pp'

class AmiOpsworks

  @config

  @opsworks
  @ec2

  def initialize(config_path = nil)

    @config = get_config(config_path)

    Aws.config.update(
        region: 'ap-northeast-1',
        credentials: Aws::Credentials.new(@config['credentials']['access_key_id'], @config['credentials']['secret_access_key'])
    )

    @opsworks = Aws::OpsWorks::Client.new(region: 'us-east-1')
    @ec2 = Aws::EC2::Client.new

  end

  def backup_ami(stack_name)

    stack = find_stack(stack_name)
    layers = find_layers(stack['stack_id'])

    layers.each do |layer|
      pp layer['name']

      instance = find_instance_by_layer(layer['layer_id'])
      instance_id = instance['ec2_instance_id']

      image_name = "#{stack_name}-#{layer['shortname']}-#{DateTime.now.strftime('%Y%m%d%H%M')}"
      image_id = create_image(instance_id, image_name)
      sleep(1)
      add_tag(image_id, stack_name, DateTime.now.strftime('%Y-%m-%d'))

      resp = @ec2.describe_images(
          image_ids: [image_id]
      )
      snapshot_id = resp['images'][0]['block_device_mappings'][0]['ebs']['snapshot_id']
      add_tag(snapshot_id, stack_name, DateTime.now.strftime('%Y-%m-%d'))

      pp "instance_id = #{instance_id}, image_id = #{image_id}, snapshot_id: #{snapshot_id}"
    end

  end

  def scavenge_amis(stack_name, remain_days_to_scavenge = 7)

    image_ids, snapshot_ids = find_scavenge_image_ids(stack_name, remain_days_to_scavenge)

    image_ids.each do |image_id|
      deregister_image(image_id)
    end

    snapshot_ids.each do |snapshot_id|
      delete_snapshot(snapshot_id)
    end

  end

  def delete_snapshot(snapshot_id)

    pp "delete snapshot #{snapshot_id}"

    @ec2.delete_snapshot(
        snapshot_id: snapshot_id
    )

  end

  def deregister_image(image_id)

    pp "delete image #{image_id}"

    @ec2.deregister_image(
        image_id: image_id
    )

  end

  def find_scavenge_image_ids(stack_name, remain_days_to_scavenge = 7)
    scavenge_date = Date.today - remain_days_to_scavenge

    resp = @ec2.describe_images(
        filters: [
            {
                name: 'tag:stack',
                values: [stack_name]
            }
        ]
    )

    images = resp.images.select do |image|
      to_be_scavenged = false
      image.tags.each do |tag|
        if tag.key == 'auto_created'
          if Date.parse(tag.value) <= scavenge_date
            to_be_scavenged = true
          end
        end
      end
      to_be_scavenged
    end

    image_ids = images.map do |image|
      image['image_id']
    end
    snapshot_ids = images.map do |image|
      image['block_device_mappings'][0]['ebs']['snapshot_id']
    end

    [image_ids, snapshot_ids]
  end

  def add_tag(resource_id, stack_name, datetime)

    @ec2.create_tags(
        resources: [resource_id],
        tags: [
            {
                key: 'stack',
                value: stack_name
            },
            {
                key: 'auto_created',
                value: datetime
            }
        ]
    )

  end

  def create_image(ec2_instance_id, image_name)

    resp = @ec2.create_image(
        instance_id: ec2_instance_id,
        name: image_name,
        description: 'Auto backuped AMI',
        no_reboot: true
    )
    resp['image_id']

  end

  def find_instance_by_layer(layer_id)

    resp = @opsworks.describe_instances(
        layer_id: layer_id
    )
    if resp.instances.length > 0
      resp.instances[0]
    end

  end

  def find_layers(stack_id)

    resp = @opsworks.describe_layers(
        stack_id: stack_id
    )
    resp.layers

  end

  def find_stack(stack_name)

    found_stack = nil
    resp = @opsworks.describe_stacks
    resp['stacks'].each do |stack|
      if stack_name == stack['name'] then
        found_stack = stack
      end
    end
    if found_stack == nil
      raise 'No stack found'
    end
    found_stack

  end

  def get_config(config_path = nil)

    config = {}
    begin

      if config_path != nil
        File.open(config_path) do |file|
          config = JSON.parse(file.read)
        end
      else
        raise 'No configuration file was specified'
      end

    rescue => ex
      raise ex
    end
    config

  end

end
