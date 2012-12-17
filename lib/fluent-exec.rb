# -*- coding: utf-8 -*-
require "fluent-exec/version"
require "fluent-logger"
require "open3"

module Fluent
  module Exec
    class CLI
      HOST = 'localhost'
      PORT = 24224

      def run(args)
        tag = args.shift
        cmd = args
        env = {}
        in_str  = ''
        out_str = ''
        err_str = ''

        begin_time = Time.now
        sin, sout, serr, thr = Open3.popen3(env, *cmd)

        sin_t = Thread.new do
          sin.write s while s = $stdin.read(1024)
          sin.close
        end

        sout_t = Thread.new do
          while s = sout.read(1024)
            out_str << s
            $stdout.write s
          end
        end

        serr_t = Thread.new do
          while s = serr.read(1024)
            err_str << s
            $stderr.write s
          end
        end

        status = thr.value
        end_time = Time.now
        #sin_t.join
        sout_t.join
        serr_t.join
        es = status.exitstatus
        #コマンドの実行を優先？
        #fluentdサーバに接続できない場合はどうする？
        # failover (file|stdout)?
        begin
          log = Fluent::Logger::FluentLogger.new(nil, :host => HOST, :port => PORT)
          log.post tag, {
            :command => ARGV,
            :exitstatus => es,
            :stdout => out_str,
            :stderr => err_str,
            :runtime => end_time - begin_time,
          }
        rescue => ex
        end
        exit es
      end
    end
  end
end
