# -*- coding: utf-8 -*-
require "fluent-exec/version"
require "fluent-logger"
require "optparse"
require "open3"

module Fluent
  module Exec
    DEFAULT_OPTS = {
      :host => 'localhost',
      :port => 24224,
      :tag => 'fluent.exec'
    }
    
    class CLI
      def initialize
        @host = DEFAULT_OPTS[:host]
        @port = DEFAULT_OPTS[:port]
        @tag = DEFAULT_OPTS[:tag]
        init_optp
      end
      
      def init_optp
        @optp = OptionParser.new        
        @optp.banner = "Usage: fluent-exec [options] [--] command..."
        @optp.separator ""
        @optp.on('-t', '--tag TAG', "Tag to use (default #{DEFAULT_OPTS[:tag]})") {|v| @tag = v}
        @optp.on('-h', '--host HOST', "Host to send (default #{DEFAULT_OPTS[:host]})") {|v| @host = v}
        @optp.on('-p', '--port PORT', /^\d+$/, "Port to send (default #{DEFAULT_OPTS[:port]})") {|v| @port = v}
      end

      def parse!(args)
        begin
          @cmd = @optp.order args
        rescue => ex
          $stderr.puts ex.to_s
          $stderr.puts @optp.help
          exit 1
        end
      end

      def io_copy_thr(from, to, str=nil)
        Thread.new do
          while s = from.read(1024)
            to.write s
            str << s if str
          end
          to.close
        end        
      end
      
      def exec
        env = {}
        in_str  = ''
        out_str = ''
        err_str = ''

        begin_time = Time.now
        sin, sout, serr, thr = Open3.popen3(env, *@cmd)

        sin_t = io_copy_thr $stdin, sin
        sout_t = io_copy_thr sout, $stdout, out_str
        serr_t = io_copy_thr serr, $stderr, err_str

        status = thr.value
        end_time = Time.now
        #sin_t.join
        sout_t.join
        serr_t.join
        es = status.exitstatus
        {
          :command => @cmd,
          :exitstatus => es,
          :stdout => out_str,
          :stderr => err_str,
          :runtime => end_time - begin_time,
        }
      end

      def run(args)
        parse! args
        record = exec
        begin
          log = Fluent::Logger::FluentLogger.new(nil, :host => @host, :port => @port)
          log.post @tag, record
        rescue => ex
        end
        exit record[:exitstatus]
      end
    end
  end
end
