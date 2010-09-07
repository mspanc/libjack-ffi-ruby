=begin
    This file is part of libjack-ffi-ruby.

    libjack-ffi-ruby is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    libjack-ffi-ruby is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with libjack-ffi-ruby.  If not, see <http://www.gnu.org/licenses/>.
=end    

module JACK
  class Port
    extend FFI::Library
    ffi_lib LIB
      
    attr_reader :pointer, :client

    FLAGS_IS_INPUT    = 0x1
    FLAGS_IS_OUTPUT   = 0x2
    FLAGS_IS_PHYSICAL = 0x4
    FLAGS_CAN_MONITOR = 0x8
    FLAGS_IS_TERMINAL = 0x10
    
    def initialize(identifier, client)
      @client = client
      
      if identifier.is_a? String
        @pointer = @client.port_by_name(identifier).pointer
      else
        @pointer = identifier
      end
    end
    
    def name
      jack_port_name @pointer
    end
    
    def flags
      jack_port_flags @pointer
    end
    
    def connect(destination)
      raise ArgumentError, "You must pass JACK::Port or String to JACK::Port.connect" if not destination.is_a? Port and not destination.is_a? String
      destination = client.port_by_name(destination) if destination.is_a? String
      
      client.connect self, destination
    end
    
    def disconnect(destination)
      raise ArgumentError, "You must pass JACK::Port or String to JACK::Port.disconnect" if not destination.is_a? Port and not destination.is_a? String
      destination = client.port_by_name(destination) if destination.is_a? String
      
      client.disconnect self, destination
    end

    def is_input?
      flags & FLAGS_IS_INPUT != 0
    end
    
    def is_output?
      flags & FLAGS_IS_OUTPUT != 0
    end
    
    def is_physical?
      flags & FLAGS_IS_PHYSICAL != 0
    end

    def can_monitor?
      flags & FLAGS_CAN_MONITOR != 0
    end

    def is_terminal?
      flags & FLAGS_IS_TERMINAL != 0
    end
    
    def to_s
      name
    end
    
    def inspect
      "#<#{self.class} name=#{name}>"
    end
    
  
    protected

=begin
enum JackPortFlags {

     /**
      * if JackPortIsInput is set, then the port can receive
      * data.
      */
     JackPortIsInput = 0x1,

     /**
      * if JackPortIsOutput is set, then data can be read from
      * the port.
      */
     JackPortIsOutput = 0x2,

     /**
      * if JackPortIsPhysical is set, then the port corresponds
      * to some kind of physical I/O connector.
      */
     JackPortIsPhysical = 0x4, 

     /**
      * if JackPortCanMonitor is set, then a call to
      * jack_port_request_monitor() makes sense.
      *
      * Precisely what this means is dependent on the client. A typical
      * result of it being called with TRUE as the second argument is
      * that data that would be available from an output port (with
      * JackPortIsPhysical set) is sent to a physical output connector
      * as well, so that it can be heard/seen/whatever.
      * 
      * Clients that do not control physical interfaces
      * should never create ports with this bit set.
      */
     JackPortCanMonitor = 0x8,

     /**
      * JackPortIsTerminal means:
      *
      * for an input port: the data received by the port
      *                    will not be passed on or made
      *                    available at any other port
      *
      * for an output port: the data available at the port
      *                    does not originate from any other port
      *
      * Audio synthesizers, I/O hardware interface clients, HDR
      * systems are examples of clients that would set this flag for
      * their ports.
      */
     JackPortIsTerminal = 0x10
};        
=end
      enum :flags, [ :is_input,    0x1,
                     :is_output,   0x2,
                     :is_physical, 0x4,
                     :can_monitor, 0x8,
                     :is_terminal, 0x10 ]
=begin
/**
 * @return the @ref JackPortFlags of the jack_port_t.
 */
int jack_port_flags (const jack_port_t *port);
=end    

      attach_function :jack_port_flags, [:pointer], :int

=begin
/**
 * @return the full name of the jack_port_t (including the @a
 * "client_name:" prefix).
 *
 * @see jack_port_name_size().
 */
const char *jack_port_name (const jack_port_t *port);
=end
      attach_function :jack_port_name, [:pointer], :string
    
  end
end
