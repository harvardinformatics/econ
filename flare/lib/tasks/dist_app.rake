desc "tar and gzip the 'app' dir"

task(:dist_app) do

  app_dir = "#{RAILS_ROOT}/app"
  dist_dir = "#{RAILS_ROOT}/dist"
  dist_app_dir = "#{dist_dir}/app"
  tgz_file = "#{dist_dir}/app.tgz"

  if File.exists?("#{dist_dir}")
    if File.exists?("#{tgz_file}")
      FileUtils.rm("#{tgz_file}")
    end
    if File.exists?("#{dist_app_dir}")
      FileUtils.rm_r("#{dist_app_dir}")
    end
  else
    FileUtils.mkdir("#{dist_dir}")
  end
  
  cmd = "svn export #{app_dir} #{dist_app_dir} && tar -C /home/maureen/econ/trunk/flare/dist -czf #{tgz_file} app/"
  puts cmd
  result = system(cmd)
  raise("tar failed.. msg: #{$?}") unless result
end
