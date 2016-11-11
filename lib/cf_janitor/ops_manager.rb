require 'net/scp'
require 'net/ssh'
require 'logger'
require 'tmpdir'
require 'uaa'
require 'httparty'

module CfJanitor
  class OPSManager
    def initialize(host_name, username, password, ssh_key_path, logger=nil)
      @host_url = "https://#{host_name}"
      @hostname = hostname
      @username = username
      @password = password
      @key_path = ssh_key_path
      @logger = logger || Logger.new($stdout)
      @config = YAMl.load_file("../config/opsmgr_url.yml")
    end

    attr_reader :logger, :host_url, :hostname :config, :username, :password, :key_path

    def strip_down_director_manifest
      director_manifest = request_opsmgr(config.fetch('urls:director_manifest'))
      unless director_manifest.nil?
        manifest = JSON.parse(director_manifest.body)
        director_ip, director_username, director_password = director_info(manifest)
      end
    end

    def init_director(director_ip, director_username, director_password)
      ip, username, password = strip_down_director_manifest
      target_bosh_director(ip)
      bosh_login(username, password)
    end

    private
    def bosh_login(username, password)
      opsmgr_ssh_user = config_fetch("opsmgr:ssh_user")
      upload_bosh_login_file(hostname, username, key_path)
      ssh_user = config_fetch("opsmgr:ssh_user")
      bosh_login_cmd = config_fetch("bosh_director:login_cmd")
      send_ssh_cmd(bosh_login_cmd, "BOSH Login", false)
    end

    def target_bosh_director(director_ip, ssl_validation=false)
      bosh_exec = config_fetch("bosh_director:bundle_path")
      bosh_root_cert = config_fetch("bosh_director:root_cert")
      opsmgr_ssh_user = config_fetch("opsmgr:ssh_username")
      send_ssh_cmd("#{bosh_exec} -n --ca-cert #{bosh_root_cert} target #{director_ip}", "BOSHTarget")
    end

    def upload_bosh_login_file(hostname, username, key_path, file_path="config/director_login.sh")
      begin
        Net::SCP.upload!(hostname, username, file_path, "/home/#{username}/", :ssh => key_path)
        unless send_ssh_cmd("ls -l /home/#{username}")
          logger.error("SCP:FilesNotListed:InUserFolder")
        end
      rescue => e
        logger.error("SCP:UploadingBOSHLoginFile:Failed: #{e}")
      end
    end

    def send_ssh_cmd(cmd, cmd_name, bosh_cmd=true)
      cmd = "#{config_fetch("bosh_director:bundle_path")} #{cmd}" if bosh_cmd
      begin
        Net::SSH.start(host_name, opsmgr_ssh_user, :password => password) do |ssh|
          bosh_output = ssh.exec!(cmd)
          if bosh_output.include? "Target set to"
            logger.info("SSHCMD:Completed:#{cmd_name}:#{bosh_output}")
          else
            logger.error("SSHCMD:Failed:#{cmd_name}:#{bosh_output}")
            return false
          end
        end
      rescue => e
        logger.error("SSHCMD:ExecError:#{e}")
        return false
      end
      return true
    end

    def request_opsmgr(query)
      url = "#{host_url}/#{query}"
      token = get_token
      response = HTTParty.get(
        url,
        headers: { 'Authorization' => "Bearer #{token}" }
      )
      if response.success?
        logger.info("OPSManager:Request:#{query}:Successful")
      else
        logge.error("OPSManager:Request:#{query}:Failed:: #{response.body}")
        return nil
      end
      response
    end

    def director_info(director_data)
      properties = manifest['manifest']['jobs']['properties']
      address = properties['director']['address']
      users = properties['uaa']['scim']['users']
      username = nil
      password = nil
      users.each do |u|
        if u.include? "director|"
          username = 'director'
          password = u.split("|")[1]
          break
        end
      end
      if username.nil? | password.nil?
        logger.error("Not able to extract BOSH Director username/password")
        logger.debug("Users: #{users}")
        return nil, nil, nil
      else
        return address, username, password
      end
    end

    def get_token
      client_id = config.fetch('client_id')
      token_issuer =  CF::UAA::TokeIssuer.new(host_url, client_id)
      token_issuer.implicit_grant_with_creds(username: username, password: password)
    end

    def config_fetch(key_name)
      key_array = key_name.split(":")
      if key_array.length <= 1
        return config.fetch(key_array[0])
      else
        l = 0
        data = config
        until l >= key_array.length do
          data = data.fetch(key_array[l])
          l += 1
        end
        return data
      end
    end

  end
end
