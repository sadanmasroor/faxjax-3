#  FileShuffler - shuffle a set on input files to a set of output files
require "array_shuffle"

class FileShuffler
  def lc_ord(char)
    char[0] - 'a'[0]
  end
  
  def splitted_files path, base
    Dir[File.join(path, "#{'%03d' % base}?")]
  end
  
  def mv_splitted_files files
    files.map do |f|
      p = Pathname.new f
      if p.basename.to_s =~ /...(.)/ 
        "mv #{p.to_s} #{p.dirname}/000#{lc_ord($1)}"
      end
    end
  end
  
  def size_list max, divisor
    out = []
    (max/divisor).times {out << divisor}
    remain = (max % divisor)
    out << remain unless remain.zero? 
    out
  end
  
  
  #  create a proc that returns a rotating number through a range
  def rotate n
    arry = (0..(n-1)).to_a.reverse
    lambda {arry.unshift(arry.pop); arry.first}
  end  
  
  #  convert numeric range to mapped array of file names with 000.ext .. nnn.ext
  def file_range(range, path=".", ext="dat")
    range.to_a.map {|n| File.join(path, "#{'%03d' % n}.#{ext}")}
  end
  
  # open mapped array of file with mode mode
  def open_files(arry, mode = "w")
    arry.map{|f| File.open f, mode}
  end
  
  # open range of files with defaults
  def open_range(range, path, mode ="w", ext="dat")
    open_files(file_range(range, path, ext), mode)
  end
  
  # close file array
  def close_files arry
    arry.map {|f| f.close}
  end
  
  # create a proc that will an out a line to one of the open files
  def fan_out arry
    rotator = rotate arry.size
    lambda {|line| arry[rotator.call].puts(line)}
  end
  
  # check if array of Files are all in EOF state
  def input_exhausted? files
    feofs = files.map {|f| f.eof?}
    feofs.inject(true) {|val, que| val && que}
  end
  
  # creat a proc that consumes a line from an aaray of open files
  def fan_in arry
    rotator = rotate arry.size
    lambda {begin arry[rotator.call].gets; rescue; end}
  end
  
  def shuffle! ifs, ofs, max, &blk
    # provide a bit of initial randomness
    ifs.shuffle!
    ofs.shuffle!

    fin = fan_in ifs
    fout = fan_out ofs
  
    until input_exhausted? ifs
      buffer = []
      count = 0
      yield "reading" if block_given?
      while count < max
        line = fin.call
        buffer << line unless line.nil?
        count = count + 1
        break if input_exhausted? ifs
      end
      yield "shuffling" if block_given?
      buffer.shuffle!  # like the plug part of an Enigma machine
      yield "writing" if block_given?
      buffer.each do |line|
        fout.call line unless line.nil?
      end
    end
    
    [ifs, ofs].each {|ar| close_files ar}
  end

  def fname_array path, ext
    Dir[File.join(path, "*.#{ext}")]
  end

  def file_array path, mode, ext="dat"
    fname_array(path, ext).map {|f| File.open(f, mode)}
  end
  
  def pathname path
    Pathname.new path
  end
  
  def shuffle_files in_path, out_path, max, ext="dat", &blk
    ifs = file_array in_path, "r", ext
    ifns = fname_array in_path, ext
    ofns = ifns.map {|fn| File.join(out_path, pathname(fn).basename.to_s) }

    p "ofs #{out_path}"
    
    p ofns
    
    ofs = ofns.map {|f| File.open f, "w"}
    
    
    p ofs
    shuffle! ifs, ofs, max, &blk
  end
  
  #  shuffle a fanned in array of files 
  def shuffle_range range, in_path, out_path, max, &blk
    ifs = open_range range, in_path, "r"
    ofs = open_range range, out_path
    shuffle! ifs, ofs, max, &blk
  end
  
end