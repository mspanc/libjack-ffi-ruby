=begin
    libjack-ffi-ruby - JACK bindings for ruby via FFI interface
    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Author: Marcin Lewandowski <marcin at saepia dot net>
=end    
    
require 'ffi'

module FFI
  class Pointer
    def read_array_of_type_until_end(type, reader)
      ary = []
      size = FFI.type_size(type)
      tmp = self
      loop do
        last = tmp.send(reader)
        break if last.null?
        ary << last
        tmp += size 
      end
      ary
    end

    def read_array_of_pointer_until_end
      read_array_of_type_until_end :pointer, :read_pointer
    end

    def read_array_of_string_until_end
      read_array_of_pointer_until_end.collect { |p| p.read_string }
    end
  end
end

module JACK
  LIB = [ "libjack.so.0.0.28", "libjack.so.0", "libjack.so", "libjack" ]  
  VERSION = "0.0.1"
end

require 'jack/errors'
require 'jack/client'
require 'jack/port'

