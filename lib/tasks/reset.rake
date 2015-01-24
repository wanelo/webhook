task reset: 'webhook:reset'

namespace :webhook do
  directory 'log'
  directory 'tmp'

  task :reset => %w(log tmp) do
    unless File.exists?('config/publishers.yml')
      File.symlink('publishers.yml.example', 'config/publishers.yml')
    end
  end
end
