require 'rbconfig'
require 'pathname'

require 'xsrb/exceptions'

#
module XenStore
  # xs_wire.h uses uint32_t
  MAX_UINT  = (2**32).freeze
  NUL       = "\x00".freeze
  CAPS_FILE = '/proc/xen/capabilities'.freeze

  # Check whether we are in dom0
  begin
    CONTROL_D = File.open(CAPS_FILE, 'rb', &:read) == "control_d\n"
  rescue Errno::ENOENT
    CONTROL_D = false
  end

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
    restrict:               20,
    reset_watches:          21,
    invalid:                MAX_UINT
  }.freeze

  # XenStore::Utils implements utility methods which are unlikely
  # to be required by users but are used by the rest of the module
  module Utils
    @reqid = -1

    @path_regex       = Regexp.new '\A[a-zA-Z0-9\-/_@]+\x00?\z'
    @watch_path_regex = Regexp.new '\A@(?:introduceDomain|releaseDomain)\x00?\z'
    @perms_regex      = Regexp.new '\A[wrbn]\d+\z'

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

        # Ensure no larger than uint32_t which is used in xs_wire.h
        @reqid %= MAX_UINT
      end

      # Get the path of the XenStore unix socket.
      #
      # @return [String] The path to the XenStore unix socket.
      def unix_socket_path
        dp = '/var/run/xenstored'
        ENV['XENSTORED_PATH'] || File.join(ENV['XENSTORED_RUNDIR'] || dp,
                                           'socket')
      end

      # Raise an exception if the provided path is invalid.
      #
      # @param path [String] The XenStore path to check.
      # @return [String] The valid path.
      def valid_path?(path)
        pathname = Pathname.new path
        max_len = pathname.absolute? ? 3072 : 2048

        if path.length > max_len
          raise XenStore::Exceptions::InvalidPath,
                "Path too long: #{path}"
        end

        unless @path_regex =~ path
          raise XenStore::Exceptions::InvalidPath,
                path.to_s
        end

        path
      end

      # Raise an exception if the provided XenStore watch path is invalid.
      #
      # @param path [String] The XenStore watch path to check.
      # @return [String] The valid path.
      def valid_watch_path?(path)
        if path.starts_with?('@') && (@watch_path_regex !~ path)
          raise XenStore::Exceptions::InvalidPath, path.to_s
        end

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
          unless perm =~ @perms_regex
            raise XenStore::Exceptions::InvalidPermission,
                  "Invalid permission string: #{perm}"
          end
        end
      end

      # Get the XenBus path on this system
      #
      # @return [String] The path to the XenBus device
      def xenbus_path
        default = '/dev/xen/xenbus'
        host_os = RbConfig::CONFIG['host_os']

        case host_os
        when 'netbsd'
          '/kern/xen/xenbus'
        when 'linux'
          File.readable?('/dev/xen/xenbus') ? '/proc/xen/xenbus' : default
        when /mswin|windows/i
          raise NotImplementedError,
                "OS '#{RbConfig::CONFIG['host_os']}' is not supported"
        else
          default
        end
      end
    end
  end
end
