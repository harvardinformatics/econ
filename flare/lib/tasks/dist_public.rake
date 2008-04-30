desc "tar and gzip the 'public' dir"

task(:dist_public) do

  public_dir = "#{RAILS_ROOT}/public"
  dist_dir = "#{RAILS_ROOT}/dist"
  dist_public_dir = "#{dist_dir}/public"
  tgz_file = "#{dist_dir}/public.tgz"

  if File.exists?("#{dist_dir}")
    if File.exists?("#{tgz_file}")
      FileUtils.rm("#{tgz_file}")
    end
    if File.exists?("#{dist_public_dir}")
      FileUtils.rm_r("#{dist_public_dir}")
    end
  else
    FileUtils.mkdir("#{dist_dir}")
  end
  
  cmd = "svn export #{public_dir} #{dist_public_dir} && tar -C /home/maureen/econ/trunk/flare/dist -czf #{tgz_file} public/"
  puts cmd
  result = system(cmd)
  raise("tar failed.. msg: #{$?}") unless result
end
