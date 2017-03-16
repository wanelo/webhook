namespace :deploy do
  before :starting, :load_unicorn_hooks do
    invoke 'unicorn:add_capistrano_hooks'
  end
end

namespace :unicorn do
  task :add_capistrano_hooks do
    after 'deploy:published', 'unicorn:restart' if fetch(:restart_unicorns, false)
    after 'deploy:published', 'unicorn:roll' if fetch(:roll_unicorns, false)
  end

  desc 'Restart unicorn'
  task :restart do
    on roles(:app) do
      execute 'svcadm restart unicorn'
    end
  end

  desc 'Restart unicorn in a "rolling" manner'
  task :roll do
    on roles(:app), in: :sequence do
      execute 'svcadm disable -s webhook'
      execute 'svcadm enable -s webhook'
    end
  end

  desc 'Start unicorn'
  task :start do
    on roles(:app) do
      execute 'svcadm enable -s webhook'
    end
  end

  desc 'Stop unicorn'
  task :stop do
    on roles(:app) do
      execute 'svcadm disable -s webhook'
    end
  end
end
