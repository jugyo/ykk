require 'digest/sha1'
require 'yaml'
require 'fileutils'

class YKK
  def self.method_missing(method, *args, &block)
    if @instance.respond_to?(method)
      @instance.__send__(method, *args, &block)
    else
      super
    end
  end

  def self.inspect
    @instance.inspect
  end

  attr_accessor :dir, :partition_size

  def initialize(options = {})
    self.dir = options[:dir]
    self.partition_size = options[:partition_size] || 0
  end

  def <<(value)
    key = key_gen(value)
    self[key] = value
    key
  end

  def [](key)
    path = file_of(key)
    return nil unless File.exists?(path)
    YAML.load(File.read(path))
  end

  def key?(key)
    !!self[key]
  end

  def []=(key, value)
    path = file_of(key)
    dirname = File.dirname(path)
    FileUtils.mkdir_p(dirname) unless File.exists?(dirname)
    File.open(path, 'wb') { |f| f << value.to_yaml }
  end

  def delete(key)
    path = file_of(key)
    File.delete(path) if File.exists?(path)
    nil
  end

  def file_of(key)
    key = key.to_s
    raise ArgumentError, 'invalid key' unless key =~ /^[\w\/]+$/
    raise "dir is not specified" unless dir
    File.join(dir, *partition(key))
  end

  def partition(key)
    return [key] unless self.partition_size > 0
    key.scan(/.{1,#{partition_size}}/)
  end

  def key_gen(value)
    Digest::SHA1.hexdigest(value.to_yaml)
  end

  def inspect
    pairs = Dir.glob(dir + '/*').map {|f|
      "#{File.basename(f).inspect}: #{YAML.load_file(f).inspect}"
    }
    "YKK(#{pairs.join ', '})"
  end

  @instance = self.new
end
