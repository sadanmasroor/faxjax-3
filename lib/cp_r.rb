def File.cp_r(from, to)
  if FileTest.file?(from)
    File.cp(from, to)
    return
  end

  start_dir = Dir.pwd

  from, to = File.expand_path(from), File.expand_path(to)
  from_contents = Dir[File.join(from, '*')]

  puts "mkpath #{to}" if $DEBUG
  File.mkpath(to)

  puts "cd #{to}" if $DEBUG
  Dir.chdir(to)

  from_contents.each do |entry|
    name = File.basename(entry)

    if FileTest.directory?(entry)
      puts "mkpath #{name}" if $DEBUG
      File.mkpath(name)
      puts "cp_r #{entry} #{name}" if $DEBUG
      cp_r(entry, name)

    else
      puts "cp #{entry} #{name}" if $DEBUG
      File.cp(entry, name)
    end
  end

  Dir.chdir(start_dir)
end

