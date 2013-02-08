# -*- coding: utf-8 --*

require 'digest/md5'

class Dir
  def self.未存在なら作成する dirname
    # 作ろうとしたディレクトリがファイルだった場合、例外が発生する
    unless File.exist? dirname
      puts "create file #{dirname}"
      Dir.mkdir dirname
    end
    return true
  end

  def self.sorted_dir baseDir
    unsorted_dir = Array.new
    unsorted_file = Array.new
    Dir.foreach baseDir do |f|
      fullpath = baseDir + "/" + f
      unsorted_dir.push  fullpath if File.ftype(fullpath) == "directory"
      unsorted_file.push fullpath if File.ftype(fullpath) == "file"
    end
    natural_sort = Proc.new do |a, b|
      cmp = a.gsub(/(\d+)/) {"%05d" % $1.to_i} <=>
            b.gsub(/(\d+)/) {"%05d" % $1.to_i}
            if cmp == 0
              a <=> b
            else
              cmp
            end
    end
    sorted_dir  = unsorted_dir.sort(&natural_sort)
    sorted_file = unsorted_file.sort(&natural_sort)
    sorted = sorted_dir + sorted_file
    return sorted
  end
end

class File
  def self.未存在なら作成する filename
    unless File.exist? filename
      puts "create file #{filename}"
      File.open(filename,"w").close
    end
    return true
  end

  def self.ファイル一覧 baseDir,拡張子
    dirInfo = Array.new
    key2path = Hash.new
    Dir.sorted_dir(baseDir).each do |fullPath|
      f = File.basename fullPath
      next if f == ".." or f == "."

      if File.ftype(fullPath) != "directory" and File.extname( f ) == 拡張子
        key = Digest::MD5.new.update fullPath
        info = {:isFolder=>false, :title =>f, 
                :key => key}
        key2path[key.to_s] = fullPath
        dirInfo.push info
        next
      end

      if File.ftype( fullPath ) =="directory"
        retInfo = {:isFolder => true, :title => f, :key => key}
        key2path[key.to_s] = fullPath
        child,key2path_ret = ファイル一覧( fullPath, 拡張子)
        unless child.empty?
          retInfo[:children] = child
          key2path.merge! key2path_ret
        end
        dirInfo.push retInfo
        next
      end
      puts "unknown file #{f}"
    end
    return dirInfo,key2path
  end

  def self.dirnameの配列にする path
    dirname = File.dirname path
    ret = dirname.split "/"
    return ret
  end
end
