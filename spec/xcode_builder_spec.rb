# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/cocoapods-pack/xcode_builder'

describe_with_private_methods XcodeBuilder do
  let(:xcodebuild_opts) { nil }

  subject do
    ui = spy
    XcodeBuilder.new('xcodeproject_path', xcodebuild_opts, 'xcodebuild_outdir', ui)
  end

  it 'breaks when giving a bad platform' do
    expect { subject.build(:windows, 'target') }.to raise_error("Unknown platform: 'windows'")
  end

  it 'raises BuildError if shellout fails' do
    expect { subject.build(:windows, 'target') }.to raise_error("Unknown platform: 'windows'")
  end

  it 'breaks with unknown type' do
    builder = subject
    mock_status = instance_double(Process::Status, success?: false, exitstatus: 42)
    allow(builder).to receive(:warn)
    allow(builder).to receive(:shellout).and_return(['error stderr', mock_status])
    expected_error_message = "Failed to execute 'xcodebuild this will totally fail'. Exit status: 42"
    expect { builder.run('xcodebuild this will totally fail') }.to raise_error(XcodeBuilder::BuildError, expected_error_message)
  end

  it 'executes xcodebuild in shell for osx' do
    builder = subject
    allow(builder).to receive(:run)
    builder.build(:osx, 'PodsTarget')
    expect(builder).to have_received(:run).with(%w[xcodebuild ONLY_ACTIVE_ARCH=NO SKIP_INSTALL=NO
                                                   BUILD_LIBRARY_FOR_DISTRIBUTION=YES
                                                   -project xcodeproject_path
                                                   -scheme "PodsTarget"
                                                   -configuration Release
                                                   EXCLUDED_SOURCE_FILE_NAMES=*-dummy.m
                                                   -destination "generic/platform=macOS"
                                                   archive
                                                   -archivePath xcodebuild_outdir/PodsTarget.xcarchive].join(' '))
  end

  it 'executes xcodebuild in shell for ios' do
    builder = subject
    allow(builder).to receive(:run)
    builder.build(:ios, 'PodsTarget')
    expect(builder).to have_received(:run).twice
    expect(builder).to have_received(:run).with(%w[xcodebuild ONLY_ACTIVE_ARCH=NO SKIP_INSTALL=NO
                                                   BUILD_LIBRARY_FOR_DISTRIBUTION=YES
                                                   -project xcodeproject_path
                                                   -scheme "PodsTarget"
                                                   -configuration Release
                                                   EXCLUDED_SOURCE_FILE_NAMES=*-dummy.m
                                                   -destination "generic/platform=iOS Simulator"
                                                   archive
                                                   -archivePath xcodebuild_outdir/PodsTarget-simulator.xcarchive].join(' '))
    expect(builder).to have_received(:run).with(%w[xcodebuild ONLY_ACTIVE_ARCH=NO SKIP_INSTALL=NO
                                                   BUILD_LIBRARY_FOR_DISTRIBUTION=YES
                                                   -project xcodeproject_path
                                                   -scheme "PodsTarget"
                                                   -configuration Release
                                                   EXCLUDED_SOURCE_FILE_NAMES=*-dummy.m
                                                   -destination "generic/platform=iOS"
                                                   archive
                                                   -archivePath xcodebuild_outdir/PodsTarget-device.xcarchive].join(' '))
  end

  it 'executes xcodebuild in shell for watchos' do
    builder = subject
    allow(builder).to receive(:run)
    builder.build(:watchos, 'PodsTarget')
    expect(builder).to have_received(:run).twice
    expect(builder).to have_received(:run).with(%w[xcodebuild ONLY_ACTIVE_ARCH=NO SKIP_INSTALL=NO
                                                   BUILD_LIBRARY_FOR_DISTRIBUTION=YES
                                                   -project xcodeproject_path
                                                   -scheme "PodsTarget"
                                                   -configuration Release
                                                   EXCLUDED_SOURCE_FILE_NAMES=*-dummy.m
                                                   -destination "generic/platform=watchOS Simulator"
                                                   archive
                                                   -archivePath xcodebuild_outdir/PodsTarget-simulator.xcarchive].join(' '))
    expect(builder).to have_received(:run).with(%w[xcodebuild ONLY_ACTIVE_ARCH=NO SKIP_INSTALL=NO
                                                   BUILD_LIBRARY_FOR_DISTRIBUTION=YES
                                                   -project xcodeproject_path
                                                   -scheme "PodsTarget"
                                                   -configuration Release
                                                   EXCLUDED_SOURCE_FILE_NAMES=*-dummy.m
                                                   -destination "generic/platform=watchOS"
                                                   archive
                                                   -archivePath xcodebuild_outdir/PodsTarget-device.xcarchive].join(' '))
  end

  context 'with non-nil xcodebuild_opts' do
    let(:xcodebuild_opts) { 'CODE_SIGNING_REQUIRED=NO' }
    it 'passes xcodebuild_opts to xcodebuild' do
      allow(subject).to receive(:run)
      subject.build(:osx, 'PodsTarget')
      expect(subject).to have_received(:run).with(%w[xcodebuild ONLY_ACTIVE_ARCH=NO SKIP_INSTALL=NO
                                                     BUILD_LIBRARY_FOR_DISTRIBUTION=YES
                                                     -project xcodeproject_path
                                                     -scheme "PodsTarget"
                                                     -configuration Release
                                                     EXCLUDED_SOURCE_FILE_NAMES=*-dummy.m
                                                     -destination "generic/platform=macOS"
                                                     CODE_SIGNING_REQUIRED=NO
                                                     archive
                                                     -archivePath xcodebuild_outdir/PodsTarget.xcarchive].join(' '))
    end
  end
end
