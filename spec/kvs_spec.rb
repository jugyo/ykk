$:.unshift File.dirname(__FILE__) + '/../lib'
require 'kvs'

describe KVS do
  before do
    @tmpdir = Dir.tmpdir
    KVS.dir = @tmpdir
  end

  it 'should generate file path' do
    KVS.file_of('foo').should == @tmpdir + '/foo'
  end

  it 'should store data' do
    KVS['foo'] = 'bar'
    KVS['foo'].should == 'bar'
    File.exists?(KVS.file_of('foo')).should be_true
  end

  it 'should store data with "<<"' do
    key = KVS << 'test'
    KVS[key].should == 'test'
    File.exists?(KVS.file_of(key)).should be_true
  end

  it 'can also use Symbol as key' do
    KVS[:foo] = 'test'
    KVS['foo'].should == 'test'
    KVS['bar'] = 'test test'
    KVS[:bar].should == 'test test'
  end

  describe 'no value exists' do
    it 'should return nil' do
      KVS['x'].should be_nil
    end
  end

  describe 'delete value' do
    it 'should delete value' do
      KVS['foo'] = 'bar'
      KVS['foo'].should == 'bar'
      KVS.delete('foo')
      KVS['foo'].should be_nil
      File.exists?(KVS.file_of('foo')).should be_false
    end

    it 'should return nil' do
      KVS['foo'] = 'bar'
      KVS.delete('foo').should be_nil
      KVS.delete('foo').should be_nil
    end
  end

  describe 'should always return nil' do
    it 'should not raise ArgumentError' do
      lambda { KVS['foo'] }.should_not raise_error(ArgumentError)
      lambda { KVS['_'] }.should_not raise_error(ArgumentError)
      lambda { KVS['1'] }.should_not raise_error(ArgumentError)
    end
  end

  describe 'use invalid key' do
    it 'should raise ArgumentError' do
      lambda { KVS['.'] }.should raise_error(ArgumentError)
      lambda { KVS['../'] }.should raise_error(ArgumentError)
      lambda { KVS['/'] }.should raise_error(ArgumentError)
    end
  end

  describe 'dir is nil' do
    before do
      KVS.dir = nil
    end

    it 'should raise ArgumentError' do
      lambda { KVS['foo'] = 'bar' }.should raise_error(RuntimeError)
      lambda { KVS['foo'] }.should raise_error(RuntimeError)
    end
  end
end