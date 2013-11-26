require 'spec_helper'

describe 'git' do
	it { should include_class('git::install') }
end
