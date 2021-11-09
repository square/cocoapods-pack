# frozen_string_literal: true

#
#  Copyright 2021 Square, Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

require 'cocoapods-pack/env_parser'
require 'English'

class XcodeBuilder
  include EnvParser
  attr_reader :xcodeproject_path, :xcodebuild_outdir, :user_interface

  class BuildError < StandardError; end
  private :user_interface

  def initialize(xcodeproject_path, xcodebuild_opts, xcodebuild_outdir, user_interface, verbose = false)
    @xcodeproject_path = xcodeproject_path
    @xcodebuild_opts = xcodebuild_opts
    @xcodebuild_outdir = xcodebuild_outdir
    @user_interface = user_interface
    @verbose = verbose
  end

  def build(platform, target, xcodebuild_args = nil)
    return build_ios(target, xcodebuild_args) if platform == :ios
    return build_osx(target, xcodebuild_args) if platform == :osx
    return build_watchos(target, xcodebuild_args) if platform == :watchos
    return build_tvos(target, xcodebuild_args) if platform == :tvos

    raise "Unknown platform: '#{platform}'"
  end

  def build_settings(platform, target, type = nil)
    return build_ios_settings(target, type) if platform == :ios
    return build_watchos_settings(target, type) if platform == :watchos
    return build_tvos_settings(target, type) if platform == :tvos

    build_osx_settings(target) if platform == :osx
  end

  private

  def verbose?
    @verbose
  end

  def build_ios(target, xcodebuild_args)
    user_interface.puts "\nBuilding #{target} for iOS...\n".yellow
    run(create_build_command(target, ios_sim_args, xcodebuild_args, :simulator))
    run(create_build_command(target, ios_device_args, xcodebuild_args, :device))
    user_interface.puts 'iOS build successful.'.green << "\n\n"
  end

  def build_osx(target, xcodebuild_args)
    user_interface.puts "\nBuilding #{target} for macOS...\n".yellow
    run(create_build_command(target, macos_args, xcodebuild_args))
    user_interface.puts 'macOS build successful.'.green << "\n\n"
  end

  def build_watchos(target, xcodebuild_args)
    user_interface.puts "\nBuilding #{target} for watchOS...\n".yellow
    run(create_build_command(target, watchos_sim_args, xcodebuild_args, :simulator))
    run(create_build_command(target, watchos_device_args, xcodebuild_args, :device))
    user_interface.puts 'watchOS build successful.'.green << "\n\n"
  end

  def build_tvos(target, xcodebuild_args)
    user_interface.puts "\nBuilding #{target} for tvOS...\n".yellow
    run(create_build_command(target, tvos_sim_args, xcodebuild_args, :simulator))
    run(create_build_command(target, tvos_device_args, xcodebuild_args, :device))
    user_interface.puts 'tvOS build successful.'.green << "\n\n"
  end

  def build_ios_settings(target, type)
    type_args = args_for_ios_type(type)
    command = create_build_command(target, type_args, '-showBuildSettings', type)
    parse_build_settings(command)
  end

  def build_osx_settings(target)
    parse_build_settings(create_build_command(target, macos_args, '-showBuildSettings'))
  end

  def build_watchos_settings(target, type)
    type_args = args_for_watchos_type(type)
    command = create_build_command(target, type_args, '-showBuildSettings', type)
    parse_build_settings(command)
  end

  def build_tvos_settings(target, type)
    type_args = args_for_tvos_type(type)
    command = create_build_command(target, type_args, '-showBuildSettings', type)
    parse_build_settings(command)
  end

  def parse_build_settings(command)
    parse_env(run(command))
  end

  def args_for_ios_type(type)
    return ios_device_args if type == :device
    return ios_sim_args if type == :simulator

    raise "Unknown type for iOS: '#{type}'"
  end

  def args_for_watchos_type(type)
    return watchos_device_args if type == :device
    return watchos_sim_args if type == :simulator

    raise "Unknown type for watchOS: '#{type}'"
  end

  def args_for_tvos_type(type)
    return tvos_device_args if type == :device
    return tvos_sim_args if type == :simulator

    raise "Unknown type for tvOS: '#{type}'"
  end

  def run(command)
    user_interface.puts command if verbose?
    output, process_status = shellout(command)
    user_interface.puts output if verbose?
    return output if process_status.success?

    warn output
    raise BuildError, "Failed to execute '#{command}'. Exit status: #{process_status.exitstatus}"
  end

  def shellout(command)
    output = `#{command}`
    [output, $CHILD_STATUS]
  end

  def create_build_command(target, sdk_args, xcodebuild_args, type = nil)
    args = [base_args(target), sdk_args]
    args << xcodebuild_args if !xcodebuild_args.nil? && !xcodebuild_args.strip.empty?
    args << @xcodebuild_opts unless @xcodebuild_opts.nil?
    args << 'archive'
    archive_path = +"-archivePath #{xcodebuild_outdir}/#{target}"
    archive_path << "-#{type}" if type
    archive_path << '.xcarchive'
    args << archive_path
    args.join(' ')
  end

  def base_args(target)
    "xcodebuild ONLY_ACTIVE_ARCH=NO SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES -project #{@xcodeproject_path}" \
      " -scheme \"#{target}\" -configuration Release EXCLUDED_SOURCE_FILE_NAMES=*-dummy.m"
  end

  def ios_sim_args
    '-destination "generic/platform=iOS Simulator"'
  end

  def ios_device_args
    '-destination "generic/platform=iOS"'
  end

  def macos_args
    '-destination "generic/platform=macOS"'
  end

  def watchos_sim_args
    '-destination "generic/platform=watchOS Simulator"'
  end

  def watchos_device_args
    '-destination "generic/platform=watchOS"'
  end

  def tvos_sim_args
    '-destination "generic/platform=tvOS Simulator"'
  end

  def tvos_device_args
    '-destination "generic/platform=tvOS"'
  end
end
