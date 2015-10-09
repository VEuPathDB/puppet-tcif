require 'spec_helper'
describe 'tcif' do

  context 'with defaults for all parameters' do
    it { should contain_class('tcif') }
  end

end
