# frozen_string_literal: true

require 'rspec'
require 'open3'

describe 'End to end Mac app testing' do
  subject do
    script = './endToEndBinMySample.sh'
    script_dir = File.join(File.dirname(__FILE__), '../')
    Dir.chdir script_dir do
      Open3.capture2e([script, script])
    end
  end

  let(:output) { subject.first }
  let(:status) { subject.last }

  xit 'compiles a mac app using cocoapods' do
    expect(output).to end_with("\nCalling MySample: MySample\n")
    expect(status).to be_success
  end
end
