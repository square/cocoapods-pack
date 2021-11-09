# frozen_string_literal: true

# Source: https://gist.github.com/akostadinov/05c2a976dc16ffee9cac

# * ruby implementation of find that follows symbolic directory links
# * tested on ruby 1.9.3, ruby 2.0 and jruby on Fedora 20 linux
# * you can use Find.prune
# * detect symlinks to dirs by path "/" suffix; does nothing with files so `symlink?` method is working fine
# * depth first order
# * detects cycles and raises an error
# * raises on broken links
# * uses recursion in the `do_find` proc when directory links are met (takes a lot of nested links until SystemStackError, that's practically never)
#
# * use like: find_follow(".") {|f| puts f}
#
# Copyright (c) 2014 Red Hat inc
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'find'
require 'pathname'

module FindFollow
  def find_follow(*paths)
    block_given? || (return enum_for(__method__, *paths))

    link_cache = {}
    link_resolve = lambda { |path|
      # puts "++ link_resolve: #{path}" # trace
      return link_cache[path] if link_cache[path]

      return link_cache[path] = Pathname.new(path).realpath.to_s
    }
    # this lambda should cleanup `link_cache` from unnecessary entries
    link_cache_reset = lambda { |path|
      # puts "++ link_cache_reset: #{path}" # trace
      # puts link_cache.to_s # trace
      link_cache.select! do |k, _v|
        path == k || k == '/' || path.start_with?(k + '/')
      end
      # puts link_cache.to_s # trace
    }
    link_is_recursive = lambda { |path|
      # puts "++ link_is_recursive: #{path}" # trace
      # the ckeck is useless if path is not a link but not our responsibility

      # we need to check full path for link cycles
      pn_initial = Pathname.new(path)
      unless pn_initial.absolute?
        # can we use `expand_path` here? Any issues with links?
        pn_initial = Pathname.new(File.join(Dir.pwd, path))
      end

      # clear unnecessary cache
      link_cache_reset.call(pn_initial.to_s)

      link_dst = link_resolve.call(pn_initial.to_s)

      pn_initial.ascend do |pn|
        return { link: path, dst: pn } if pn != pn_initial && link_dst == link_resolve.call(pn.to_s)
      end

      return false
    }

    do_find = proc { |path|
      Find.find(path) do |result|
        if File.symlink?(result) && File.directory?(File.realpath(result))
          if result[-1] == '/'
            # probably hitting https://github.com/jruby/jruby/issues/1895
            yield(result.dup)
            Dir.new(result).each do |subpath|
              do_find.call(result + subpath) unless ['.', '..'].include?(subpath)
            end
          elsif is_recursive = link_is_recursive.call(result)
            raise "cannot handle recursive links: #{is_recursive[:link]} => #{is_recursive[:dst]}"
          else
            do_find.call(result + '/')
          end
        else
          yield(result)
        end
      end
    }

    while path = paths.shift
      do_find.call(path)
    end
  end
end
