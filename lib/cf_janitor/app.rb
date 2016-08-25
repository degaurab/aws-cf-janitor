require 'sinatra'
require 'yaml'
require 'logger'

require_relative 'aws_manager'

module CfJanitor
  class App < Sinatra::Base
    configure { set :root, File.join(File.dirname(__FILE__), '..', '..') }


    def initialize
      @sequence_data = YAML.load_file(File.join(File.dirname(__FILE__), '..', '..', '/config/start_stop_sequence.yml'))
      @logger = logger || Logger.new($stdout)
      @start_seq_data = {}
      @stop_seq_data = {}
      super
    end

    attr_accessor :sequence_data, :logger, :start_seq_data, :stop_seq_data

    get '/' do
      erb :'index.html', { :layout => :'layout.html' }
    end

    post '/get_sequence' do
      puts "Params: #{params}"
      puts "#{params['aws_access_id'].nil? | params['aws_access_id'].nil?}"
      if !(params['aws_access_id'].empty? | params['aws_secret_key'].empty?)
        aws_manager = AwsManager.new(params['aws_access_id'], params['aws_secret_key'], params['region'], logger)
        start_seq_data, stop_seq_data = aws_manager.list_sequence(params['deployment_name'], sequence_data)
        logger.debug(start_seq_data)
        logger.debug(stop_seq_data)
      end

      redirect '/sequence_data'
    end

    get '/sequence_data' do
      erb :'sequence_data.html', {:layout => :'layout.html'}
    end
  end
end
