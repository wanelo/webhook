@worker_processes = ENV['WORKER_PROCESSES'] || 2
@working_directory = ENV['WORKING_DIRECTORY'] || File.expand_path('../..', __FILE__)
@timeout = ENV['UNICORN_TIMEOUT'] || 11
@pidfile = ENV['UNICORN_PIDFILE'] || 'tmp/webhook.pid'
@stderr_log = ENV['UNICORN_STDERR'] || 'log/webhook.stderr.log'
@stdout_log = ENV['UNICORN_STDOUT'] || 'log/webhook.stdout.log'

worker_processes @worker_processes.to_i

working_directory @working_directory

# nuke workers after N seconds instead of 60 seconds (the default)
timeout @timeout.to_i

pid @pidfile

# By default, the Unicorn logger will write to stderr.
# Additionally, ome applications/frameworks log to stderr or stdout,
# so prevent them from going to /dev/null when daemonized here:
stderr_path @stderr_log
stdout_path @stdout_log

# combine Ruby 2.0.0dev or REE with "preload_app true" for memory savings
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
GC.respond_to?(:copy_on_write_friendly=) and GC.copy_on_write_friendly = true
GC::Profiler.enable
