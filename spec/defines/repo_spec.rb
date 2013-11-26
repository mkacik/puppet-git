require 'spec_helper'

describe 'git::repo' do
  let(:title) { 'some repository' }
  
  describe 'local source' do
    let(:params) { { 
      :source => '/var/local/somerepo.git',
      :path => '/some/target/some.dir',
      :owner => 'root'
    } }

    it 'fails with error if local repository is given' do
      expect { should include_class('git') }.to raise_error(Puppet::Error)
    end
  end

  describe 'remote source' do
    let(:params) { { 
      :source => 'git@github.com:mkacik/dotfiles.git',
      :path => '/some/target/some.dir',
      :owner => 'root'
    } }

    it { should include_class('git') }
    it { should contain_exec('checkout git branch master in /some/target/some.dir') }
  end

  describe 'tag defined' do
    let(:params) { { 
      :source => 'git@github.com:mkacik/dotfiles.git',
      :path => '/some/target/some.dir',
      :owner => 'root',
      :git_tag => '1.0'
    } }

    it { should contain_exec('checkout git tag 1.0 in /some/target/some.dir') }
  end

  describe 'tag defined & update = true' do
    let(:params) { { 
      :source => 'git@github.com:mkacik/dotfiles.git',
      :path => '/some/target/some.dir',
      :owner => 'root',
      :git_tag => 'dev',
      :update => true,
    } }
    
    it 'fails with error if both update flag and git tag are set' do
      expect { should include_class('git') }.to raise_error(Puppet::Error)
    end
  end
  
  describe 'update = true' do
    let(:params) { { 
      :source => 'git@github.com:mkacik/dotfiles.git',
      :path => '/some/target/some.dir',
      :owner => 'root',
      :branch => 'dev',
      :update => true,
    } }

    it { should contain_exec('checkout git branch dev in /some/target/some.dir') }
    it { should contain_exec('pull new changes from branch dev in /some/target/some.dir') }
  end


end
