#!/usr/bin/env ../script/runner

require 'rubygems'
require 'daemons'

Daemons.run('imap_task.rb')

#process_messages = Daemons.call do
#  queue_log = File.new("queue.log", "w")
#  loop {
#    queue_log.puts("Thinking...")
#    queue_log.flush
#    sleep(SLEEP_TIME)
#  }
#  queue_log.puts("STOPPING")
#  queue_log.close
#end
