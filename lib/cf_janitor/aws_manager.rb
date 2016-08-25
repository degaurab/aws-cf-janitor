require 'aws-sdk-v1'

module CfJanitor
  class AwsManager
    def initialize(aws_access_key_id, aws_secret_access_key, region, logger=nil)
      aws_access_key_id = aws_access_key_id
      aws_secret_access_key = aws_secret_access_key
      @ec2_client = AWS::EC2.new(region: region, access_key_id: aws_access_key_id, secret_access_key: aws_secret_access_key)
      @logger = logger || Logger.new($stdout)
    end
    attr_reader :logger

    def list_sequence (deployment_name, sequence)
      instance_map = create_instance_map(deployment_name)
      instance_key_list = instance_map.keys
      start_sequence ={}
      stop_sequence = {}
      logger.debug("AwsManager::InstanceMap:#{instance_map}")
      sequence['start_sequence'].each do |component|
        job_name = component['job_name_prefix']
        all_azs = instance_key_list.select{|instance| instance.match(/^#{job_name}(|_\w\d)\/\d/)}
        start_sequence[job_name] = []
        if !all_azs.empty?
          logger.debug("AwsManager::AllMappedInstances:#{all_azs}")
          all_azs.each do |az|
            start_sequence[job_name] << instance_map[az]
          end
        else
          logger.debug("AwsManager::NoInstance:JobName:#{job_name}")
        end

      end

      # TODO: start <--> stop sequence seems to be just reverse.
      #       so maybe we dont need to create list twice.

      sequence['stop_sequence'].each do |component|
        job_name = component['job_name_prefix']
        all_azs = instance_key_list.select{|instance| instance.match(/^#{job_name}(|_\w\d)\/\d/)}
        stop_sequence[job_name] = []
        if !all_azs.empty?
          logger.debug("AwsManager::AllMappedInstances:#{all_azs}")
          all_azs.each do |az|
            stop_sequence[job_name] << instance_map[az]
          end
        else
          logger.debug("AwsManager::NoInstance:JobName:#{job_name}")
        end
      end
      return start_sequence, stop_sequence
    end

    private

    def create_instance_map(deployment_name)
      instances = fetch_instances_for_deployment(deployment_name)
      logger.info("AwsManager::CreatingInstanceMap")
      instances = instances.inject({}) { |m, i| m["#{i.tags.to_h['job']}/#{i.tags.to_h['index']}"] = i.id ; m }
      return instances
    end

    def fetch_instances_for_deployment(deployment_name)
      logger.info("AWS::GettingInstance")
      @ec2_client.instances.filter('tag:deployment', deployment_name)
    end
  end
end
