task :reset do
  File.unlink('config/publishers.yml')
  File.symlink('publishers.yml.example', 'config/publishers.yml')
end
