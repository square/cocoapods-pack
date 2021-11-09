# frozen_string_literal: true

require 'rspec'
require_relative '../lib/cocoapods-pack/env_parser'

describe EnvParser do
  include EnvParser

  it 'can parse env variables into a hash' do
    build_settings = <<-BUILDSETTINGS
    LD_NO_PIE = NO
    LD_QUOTE_LINKER_ARGUMENTS_FOR_COMPILER_DRIVER = YES
    LINK_FILE_LIST_normal_i386 =
    BUILDSETTINGS
    hash = { 'LD_NO_PIE' => 'NO', 'LD_QUOTE_LINKER_ARGUMENTS_FOR_COMPILER_DRIVER' => 'YES' }
    expect(parse_env(build_settings)).to eq hash
  end
end
