require 'pp'
require "fileutils"
require 'sign_code_generator'
require "file_shuffler"
# require 'math'

class SignUtil
  def self.reset_expired_signs
    signs = Sign.find_by_sql("SELECT * FROM signs WHERE ADDDATE(activated_on,duration+30) < CURDATE()")
    if !signs.nil? && !signs.empty?
      sign_ids = []
      signs.each do |sign|
        sign_ids << sign.id
      end
      Sign.reset(sign_ids)
      puts "Reset #{sign_ids.length} signs"
    end
  end

  def self.RESET_SIGNS_LISTINGS_ORDERS
    conn = ActiveRecord::Base.connection
    results = conn.execute('TRUNCATE TABLE `sign_lots_signs`')
    results = conn.execute('TRUNCATE TABLE `signs`')
    results = conn.execute('TRUNCATE TABLE `sign_lots`')
    results = conn.execute('TRUNCATE TABLE `listing_values`')
    results = conn.execute('TRUNCATE TABLE `listings`')
    results = conn.execute('TRUNCATE TABLE `orders`')
  end

  def self.batch_path
    File.expand_path(File.join(RAILS_ROOT, 'batches'))
  end

  MAX_SIGNS = (36 ** 4 *10) # maximum of '0AAAA- 99999' possible values 
  BUUFER_LIMIT = 100000     # tradeoff to limit to a reasonable size, thus avoiding much GC 
  
  #  call the sign code generator and output to 1 or more files
  #  of sz_buffer size upto max maximun# of signs, optionally shuffling 
  # them in place before output (default is to shuffle)
  # internally the buffer is limited to 100K for memory/GC performance

  def self.generate_files sz_buffer, start=1, max=MAX_SIGNS, shuffle = true
    a=SignCodeGenerator.new
    fs = FileShuffler.new # used for outpt file handling
    current = start
    fs.size_list(max, sz_buffer).each_with_index do |size, ndx|
      puts "generating #{current} size #{size}"
      File.open(File.join(self.batch_path, "#{'%03d' % ndx}.dat"), "w") do |f|
        a.generate_signs size, current do |code, key|
          f.puts "#{code},#{key}" 
        end
      end
      current += size
    end
  end

  def self.run_batches start, per_batch, count, shuffle = true
    0.upto(count-1) do |batch|
      puts "self.generate_file #{per_batch}, #{(batch * per_batch) + start} "
      puts self.generate_file per_batch, (batch * per_batch) + start, shuffle
    end
  end
  
  def self.shuffle_batches(sz_buffer)
    fs = FileShuffler.new
    fs.shuffle_files  self.batch_path, File.join(self.batch_path, "shuffled"), sz_buffer do |message|
      puts message
    end
  end

  def self.full_path(path)
    File.join(File.expand_path(RAILS_ROOT), path)
  end

  def self.clip_file(path, qty)
    orig_path = Pathname.new path
    
    path = self.full_path path
    p = Pathname.new path
    base = p.basename.to_s
    dir = p.dirname
    ext = p.extname
    total = `wc -l #{path}`.split()[0].to_i
    puts "total #{total}"
    final = total - qty
    puts "will clip #{qty} from #{path}"
    puts "final #{final}"
    newname=p.basename(p.extname).to_s+"-#{Time.now.strftime('%Y%m%d%H%M%S')}#{ext}"
    oldname = p.basename(p.extname).to_s+"-old#{ext}"
    usedpath = File.join(dir.dirname, "used", newname)
    oldpath = File.join(dir, oldname)
    `head -#{qty} #{path} >#{usedpath}`
    `tail -#{final} #{path} >#{oldpath}`
 
    FileUtils.mv oldpath, path
    puts "clipped file - #{usedpath}"
    puts "LOAD THIS:"
    puts File.join(orig_path.dirname.dirname, 'used', newname).to_s
    puts "old file"
    p `wc -l #{path}`
  end

  def self.load_signs(path)
    start = Sign.count
    path = self.full_path path
    env = (RAILS_ENV == 'production' ? 'LOCAL' : '')
    stmt  = <<-EOS
LOAD DATA #{env} INFILE '#{path}' 
INTO TABLE signs 
FIELDS TERMINATED BY ','
 (code, `key`);    
EOS
    puts '----'
    puts stmt
    puts '----'
    
    conn = ActiveRecord::Base.connection
    conn.execute(stmt)
    puts "#{Sign.count - start} signs loaded"
    
    stmt  = <<-EOS
UPDATE signs
SET duration = 180
WHERE duration IS NULL
    EOS
    
    puts '---'
    puts stmt
    conn.execute(stmt)
  end

  def self.generate_and_insert_sign_codes
    a=SignCodeGenerator.new
    a.generate(150000)

    my_file = File.new("#{RAILS_ROOT}/lib/_tmp_infile.sql", "w")
    a.codes.each_index do |i|
      my_file.puts a.codes[i].to_s+","+a.keys[i].to_s+"\n"
    end
    my_file.close

    conn = ActiveRecord::Base.connection
    stmt =  "LOAD DATA LOCAL INFILE '~/faxjax/lib/_tmp_infile.sql' "
    stmt += "INTO TABLE signs "
    stmt += "FIELDS TERMINATED BY ',' "
    stmt += "LINES TERMINATED BY '\n' "
    stmt += "(code, `key`);"
    conn.execute(stmt)
  end

end




