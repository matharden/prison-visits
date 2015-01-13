worker_processes 4
listen 3000, :backlog => 64
working_directory "/app"
pid "/app/unicorn.pid"
timeout 30
preload_app true
#stderr_path "/var/log/unicorn_stderr.log"
#stdout_path "/var/log/unicorn_stdout.log"

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
