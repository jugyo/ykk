$:.unshift File.dirname(__FILE__) + '/../lib'
require 'ykk'
require 'tmpdir'
require 'fileutils'

describe YKK do
  before do
    @tmpdir = Dir.tmpdir + '/ykk_test'
    FileUtils.rm_rf(@tmpdir)
    YKK.dir = @tmpdir
  end

  it 'generates file path' do
    YKK.file_of('foo').should == @tmpdir + '/foo'
    YKK.file_of('foo/bar').should == @tmpdir + '/foo/bar'
  end

  it 'stores data' do
    YKK['foo'] = {:a => 'b', :c => 'd'}
    YKK['foo'].should == {:a => 'b', :c => 'd'}
    File.exists?(YKK.file_of('foo')).should be_true
    YKK['a/b'] = {:e => 'f', :g => 'h'}
    YKK['a/b'].should == {:e => 'f', :g => 'h'}
    File.exists?(YKK.file_of('a/b')).should be_true
  end

  it 'should store data with "<<"' do
    key = YKK << {:a => 'b', :c => 'd'}
    YKK[key].should == {:a => 'b', :c => 'd'}
    File.exists?(YKK.file_of(key)).should be_true
  end

  it 'can also use Symbol as key' do
    YKK[:foo] = 'test'
    YKK['foo'].should == 'test'
    YKK['bar'] = 'test test'
    YKK[:bar].should == 'test test'
  end

  describe 'no value exists' do
    it 'should return nil' do
      YKK['x'].should be_nil
    end
  end

  describe 'delete value' do
    it 'should delete value' do
      YKK['foo'] = 'bar'
      YKK['foo'].should == 'bar'
      YKK.delete('foo')
      YKK['foo'].should be_nil
      File.exists?(YKK.file_of('foo')).should be_false
    end

    it 'should return nil' do
      YKK['foo'] = 'bar'
      YKK.delete('foo').should be_nil
      YKK.delete('foo').should be_nil
    end
  end

  describe 'should always return nil' do
    it 'should not raise ArgumentError' do
      lambda { YKK['foo'] }.should_not raise_error(ArgumentError)
      lambda { YKK['_'] }.should_not raise_error(ArgumentError)
      lambda { YKK['1'] }.should_not raise_error(ArgumentError)
    end
  end

  describe 'use invalid key' do
    it 'raises ArgumentError' do
      lambda { YKK['.'] }.should raise_error(ArgumentError)
      lambda { YKK['../'] }.should raise_error(ArgumentError)
    end
  end

  describe 'dir is nil' do
    before do
      YKK.dir = nil
    end

    it 'raises ArgumentError' do
      lambda { YKK['foo'] = {:a => 'b'} }.should raise_error(RuntimeError)
      lambda { YKK['foo'] }.should raise_error(RuntimeError)
    end
  end

  describe 'instantiate' do
    before do
      @tmpdir_for_foo = Dir.tmpdir + '/ykk_test_foo'
      FileUtils.rm_rf(@tmpdir_for_foo)
      @ykk = YKK.new(@tmpdir_for_foo)
    end

    it 'generates file path' do
      @ykk.file_of('foo').should == @tmpdir_for_foo + '/foo'
    end

    it 'stores data' do
      @ykk['bar'] = 'bar'
      @ykk['bar'].should == 'bar'
      YKK['bar'].should_not == 'bar'
    end
  end

  describe 'YKK#inspect' do
    before do
      @tmpdir = Dir.tmpdir + '/ykk_test'
      FileUtils.rm_rf(@tmpdir)
      YKK.dir = @tmpdir
    end

    it 'shows the pairs of key and value' do
      YKK.inspect.should == 'YKK()'

      YKK['foo'] = 'bar'
      YKK.inspect.should == 'YKK("foo": "bar")'
    end
  end
end
