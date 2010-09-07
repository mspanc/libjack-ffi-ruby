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
  class Client
    extend FFI::Library
    ffi_lib LIB
    
    attr_reader :pointer
    
    def initialize(name, options = 0x00, &b)
      @name = name
      @options = options
      
      status = FFI::MemoryPointer.new :pointer
      
      @server = jack_client_open name, options, status
      # TODO return status handling
      
      if block_given?
        yield self
        close
      end
      
    end

    def close
      jack_client_close @server
    end
    
    def get_ports
      # TODO checking if i am connected
      # TODO parameters
      jack_get_ports(@server, nil, nil, 0).read_array_of_string_until_end.collect{ |port| puts port; Port.new(port, self) }
    end
    
    def port_by_name(name)
      port = jack_port_by_name(@server, name)
      
      raise Errors::NoSuchPortError, "There no such port as #{name}" if port.null?
      
      Port.new(port, self)
    end
    
    def connect(source, destination)
      change_graph(:connect, source, destination) == 0
    end
    
    def disconnect(source, destination)
      change_graph(:disconnect, source, destination) == 0
    end

    def change_graph(method, source, destination)
      raise ArgumentError, "You must pass JACK::Port or String to JACK::Client.port_connect" if not source.is_a? Port and not source.is_a? String and not destination.is_a? Port and not destination.is_a? String
      
      source = port_by_name(source) if source.is_a? String
      destination = port_by_name(destination) if destination.is_a? String

      if source.is_input? and destination.is_output?
        source = destination
        destination = source
      elsif source.is_output? and destination.is_input?
        # Direction ok
      else
        raise Errors::InvalidPortsChosenToConnect, "Cannot connect ports #{source} and #{destination} - both are input or output ports"
      end

      # TODO checking result
      send("jack_#{method}", @server, source.name, destination.name)    
    end

    protected

=begin
  enum JackOptions {

       /**
        * Null value to use when no option bits are needed.
        */
       JackNullOption = 0x00,

       /**
        * Do not automatically start the JACK server when it is not
        * already running.  This option is always selected if
        * \$JACK_NO_START_SERVER is defined in the calling process
        * environment.
        */
       JackNoStartServer = 0x01,

       /**
        * Use the exact client name requested.  Otherwise, JACK
        * automatically generates a unique one, if needed.
        */
       JackUseExactName = 0x02,

       /**
        * Open with optional <em>(char *) server_name</em> parameter.
        */
       JackServerName = 0x04,

       /**
        * Load internal client from optional <em>(char *)
        * load_name</em>.  Otherwise use the @a client_name.
        */
       JackLoadName = 0x08,

       /**
        * Pass optional <em>(char *) load_init</em> string to the
        * jack_initialize() entry point of an internal client.
        */
       JackLoadInit = 0x10
  };
=end
    enum :options, [ :null_option,     0x00,
                     :no_start_server, 0x01,
                     :use_exact_name,  0x02,
                     :server_name,     0x04,
                     :load_name,       0x08,
                     :load_init,       0x10 ]
    
=begin
  enum JackStatus {

       /**
        * Overall operation failed.
        */
       JackFailure = 0x01,

       /**
        * The operation contained an invalid or unsupported option.
        */
       JackInvalidOption = 0x02,

       /**
        * The desired client name was not unique.  With the @ref
        * JackUseExactName option this situation is fatal.  Otherwise,
        * the name was modified by appending a dash and a two-digit
        * number in the range "-01" to "-99".  The
        * jack_get_client_name() function will return the exact string
        * that was used.  If the specified @a client_name plus these
        * extra characters would be too long, the open fails instead.
        */
       JackNameNotUnique = 0x04,

       /**
        * The JACK server was started as a result of this operation.
        * Otherwise, it was running already.  In either case the caller
        * is now connected to jackd, so there is no race condition.
        * When the server shuts down, the client will find out.
        */
       JackServerStarted = 0x08,

       /**
        * Unable to connect to the JACK server.
        */
       JackServerFailed = 0x10,

       /**
        * Communication error with the JACK server.
        */
       JackServerError = 0x20,

       /**
        * Requested client does not exist.
        */
       JackNoSuchClient = 0x40,

       /**
        * Unable to load internal client
        */
       JackLoadFailure = 0x80,

       /**
        * Unable to initialize client
        */
       JackInitFailure = 0x100,

       /**
        * Unable to access shared memory
        */
       JackShmFailure = 0x200,

       /**
        * Client's protocol version does not match
        */
       JackVersionError = 0x400,

       /*
        * BackendError
        */
       JackBackendError = 0x800,

       /*
        * Client is being shutdown against its will
        */
       JackClientZombie = 0x1000
  };
=end  

    enum :status, [ :failure,         0x01,
                    :invalid_option,  0x02,
                    :name_not_unique, 0x04,
                    :server_started,  0x08,
                    :server_failed,   0x10,
                    :server_error,    0x20,
                    :no_such_client,  0x40,
                    :load_failure,    0x80,
                    :init_failure,    0x100,
                    :shm_failure,     0x200,
                    :version_error,   0x400,
                    :backend_error,   0x800,
                    :client_zombie,   0x1000 ]
=begin
  /**
   * Open an external client session with a JACK server.  This interface
   * is more complex but more powerful than jack_client_new().  With it,
   * clients may choose which of several servers to connect, and control
   * whether and how to start the server automatically, if it was not
   * already running.  There is also an option for JACK to generate a
   * unique client name, when necessary.
   *
   * @param client_name of at most jack_client_name_size() characters.
   * The name scope is local to each server.  Unless forbidden by the
   * @ref JackUseExactName option, the server will modify this name to
   * create a unique variant, if needed.
   *
   * @param options formed by OR-ing together @ref JackOptions bits.
   * Only the @ref JackOpenOptions bits are allowed.
   *
   * @param status (if non-NULL) an address for JACK to return
   * information from the open operation.  This status word is formed by
   * OR-ing together the relevant @ref JackStatus bits.
   *
   *
   * <b>Optional parameters:</b> depending on corresponding [@a options
   * bits] additional parameters may follow @a status (in this order).
   *
   * @arg [@ref JackServerName] <em>(char *) server_name</em> selects
   * from among several possible concurrent server instances.  Server
   * names are unique to each user.  If unspecified, use "default"
   * unless \$JACK_DEFAULT_SERVER is defined in the process environment.
   *
   * @return Opaque client handle if successful.  If this is NULL, the
   * open operation failed, @a *status includes @ref JackFailure and the
   * caller is not a JACK client.
   */
  jack_client_t *jack_client_open (const char *client_name,
                                   jack_options_t options,
                                   jack_status_t *status, ...);

=end                                 
    attach_function :jack_client_open, [:string, :options, :pointer], :pointer


=begin
  /**
   * Disconnects an external client from a JACK server.
   *
   * @return 0 on success, otherwise a non-zero error code
   */
  int jack_client_close (jack_client_t *client);
=end
    attach_function :jack_client_close, [:pointer], :int

=begin
  /**
   * @param port_name_pattern A regular expression used to select 
   * ports by name.  If NULL or of zero length, no selection based 
   * on name will be carried out.
   * @param type_name_pattern A regular expression used to select 
   * ports by type.  If NULL or of zero length, no selection based 
   * on type will be carried out.
   * @param flags A value used to select ports by their flags.  
   * If zero, no selection based on flags will be carried out.
   *
   * @return a NULL-terminated array of ports that match the specified
   * arguments.  The caller is responsible for calling free(3) any
   * non-NULL returned value.
   *
   * @see jack_port_name_size(), jack_port_type_size()
   */
  const char **jack_get_ports (jack_client_t *, 
                               const char *port_name_pattern, 
                               const char *type_name_pattern, 
                               unsigned long flags);

=end
    attach_function :jack_get_ports, [:pointer, :string, :string, :ulong], :pointer


=begin
  /**
   * @return address of the jack_port_t named @a port_name.
   *
   * @see jack_port_name_size()
   */
  jack_port_t *jack_port_by_name (jack_client_t *, const char *port_name);
=end
    attach_function :jack_port_by_name, [:pointer, :string], :pointer

=begin
/**
 * Establish a connection between two ports.
 *
 * When a connection exists, data written to the source port will
 * be available to be read at the destination port.
 *
 * @pre The port types must be identical.
 *
 * @pre The @ref JackPortFlags of the @a source_port must include @ref
 * JackPortIsOutput.
 *
 * @pre The @ref JackPortFlags of the @a destination_port must include
 * @ref JackPortIsInput.
 *
 * @return 0 on success, EEXIST if the connection is already made,
 * otherwise a non-zero error code
 */
int jack_connect (jack_client_t *,
                  const char *source_port,
                  const char *destination_port);
=end
  attach_function :jack_connect, [:pointer, :string, :string], :int    

=begin
/**
 * Remove a connection between two ports.
 *
 * @pre The port types must be identical.
 *
 * @pre The @ref JackPortFlags of the @a source_port must include @ref
 * JackPortIsOutput.
 *
 * @pre The @ref JackPortFlags of the @a destination_port must include
 * @ref JackPortIsInput.
 *
 * @return 0 on success, otherwise a non-zero error code
 */
int jack_disconnect (jack_client_t *,
                     const char *source_port,
                     const char *destination_port);
=end
  attach_function :jack_disconnect, [:pointer, :string, :string], :int
  
=begin
/**
 * Perform the same function as jack_disconnect() using port handles
 * rather than names.  This avoids the name lookup inherent in the
 * name-based version.
 *
 * Clients connecting their own ports are likely to use this function,
 * while generic connection clients (e.g. patchbays) would use
 * jack_disconnect().
 */
int jack_port_disconnect (jack_client_t *, jack_port_t *);
=end
  attach_function :jack_port_disconnect, [:pointer, :pointer], :int

  end
end
