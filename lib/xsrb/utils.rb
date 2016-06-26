require 'rbconfig'
require 'pathname'

require 'xsrb/exceptions'

module XenStore
  OPERATIONS = {
    debug:                  0,
    directory:              1,
    read:                   2,
    get_perms:              3,
    watch:                  4,
    unwatch:                5,
    transaction_start:      6,
    transaction_end:        7,
    introduce:              8,
    release:                9,
    get_domain_path:        10,
    write:                  11,
    mkdir:                  12,
    rm:                     13,
    set_perms:              14,
    watch_event:            15,
    error:                  16,
    is_domain_introduced:   17,
    resume:                 18,
    set_target:             19,
    restrict:               128
  }.freeze

  # XenStore::Utils implements utility methods which are unlikely
  # to be required by users but are used by the rest of the module
  module Utils
    class Integer
      N_BYTES = [42].pack('i').size
      N_BITS = N_BYTES * 16
      MAX = 2**(N_BITS - 2) - 1
      MIN = -MAX - 1
    end

    @reqid = -1

    @path_regex = Regexp.new '\A[a-zA-Z0-9-/_@]+\x00?\z'
    @watch_path_regex = Regexp.new '\A@(?:introduceDomain|releaseDomain)\x00?\z'
    @permissions_regex = Regexp.new '\A[wrbn]\d+\z'

    @errno_exception_map = Hash[
      Errno.constants.collect do |n|
        [Errno.const_get(n)::Errno, Errno.const_get(n)]
      end.reverse
    ].freeze

    class << self
      # Convert an error number or symbol to an Errno exception
      #
      # @param n [Integer, Symbol] An +Integer+ or +symbol+ representing the
      #                            Errno exception to return.
      # @return [Exception] The +Exception+ representing the provided type
      #                     of error.
      def error(n)
        if n.is_a? Integer
          @errno_exception_map[n]
        else
          Errno.send(n)
        end
      end

      # Get the next request ID to contact XenStore with.
      #
      # @return [Integer] The next ID in the sequence.
      def next_request_id
        @reqid += 1
        @reqid %= Integer::MAX
      end

      # Get the path of the XenStore unix socket.
      #
      # @return [String] The path to the XenStore unix socket.
      def unix_socket_path
        ENV['XENSTORED_PATH'] || File.join(ENV['XENSTORED_RUNDIR'], 'socket')
      end

      # Raise an exception if the provided path is invalid.
      #
      # @param path [String] The XenStore path to check.
      # @return [String] The valid path.
      def valid_path?(path)
        pathname = Pathname.new path
        max_len = pathname.absolute? ? 3072 : 2048

        raise XenStore::Exceptions::InvalidPath,
              "Path too long: #{path}" if path.length > max_len

        raise XenStore::Exceptions::InvalidPath,
              path.to_s unless @path_regex =~ path

        path
      end

      # Raise an exception if the provided XenStore watch path is invalid.
      #
      # @param path [String] The XenStore watch path to check.
      # @return [String] The valid path.
      def valid_watch_path?(path)
        raise XenStore::Exceptions::InvalidPath,
              path.to_s if path.starts_with?('@') &&
                           !(@watch_path_regex =~ path)

        valid_path? path
      end

      # Check if every member of a list of permissions strings is valid.
      #
      # @param perms [Array, String] An +Array+ of XenStore permissions
      #                              specifications
      # @return [Array] The list of permissions.
      def valid_permissions?(perms)
        perms = [perms] if perms.is_a? String
        perms.each do |perm|
          unless perm =~ @permissions_regex
            raise XenStore::Exceptions::UnknownPermission,
                  "Invalid permission string: #{perm}"
          end
        end
      end

      # Get the XenBus path on this system
      #
      # @return [String] The path to the XenBus device
      def xenbus_path
        case RbConfig::CONFIG['host_os']
        when /mswin|windows/i
          # Windows
        when /linux|arch/i
          # Linux
        when /sunos|solaris/i
          # Solaris
        when /darwin/i
          # MAC OS X
        else
          raise NotImplementedError,
                "OS '#{RbConfig::CONFIG['host_os']}' is not supported"
        end
      end
    end
  end
end
