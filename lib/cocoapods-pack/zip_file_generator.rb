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

require 'zip'

class ZipFileGenerator
  def initialize(input_dir, output_file)
    @input_dir = input_dir
    @output_file = output_file
  end

  def write(&skip_filter_block)
    entries = Dir.entries(@input_dir)
    entries.delete('.')
    entries.delete('..')
    begin
      io = Zip::File.open(@output_file, Zip::File::CREATE)
      write_entries(entries, '', io, &skip_filter_block)
    ensure
      io.close
    end
  end

  private

  def write_entries(entries, path, io, &skip_filter_block)
    entries.each do |e|
      zip_file_path = path == '' ? e : File.join(path, e)
      disk_file_path = File.join(@input_dir, zip_file_path)
      if File.directory?(disk_file_path)
        io.mkdir(zip_file_path)
        subdir = Dir.entries(disk_file_path)
        subdir.delete('.')
        subdir.delete('..')
        write_entries(subdir, zip_file_path, io, &skip_filter_block)
      elsif skip_filter_block.nil? || !yield(disk_file_path)
        io.get_output_stream(zip_file_path) { |f| f.write(IO.binread(disk_file_path)) }
      end
    end
  end
end
