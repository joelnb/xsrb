require 'rbconfig'

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

  EXCEPTIONS = Hash[
    Errno.constants.collect do |n|
      [Errno.const_get(n)::Errno, Errno.const_get(n)]
    end.reverse
  ].freeze

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

    class << self
      def error(n)
        EXCEPTIONS[n]
      end

      def next_request_id
        @reqid += 1
        @reqid %= Integer::MAX
      end

      def unix_socket_path
        ENV['XENSTORED_PATH'] || File.join(ENV['XENSTORED_RUNDIR'], 'socket')
      end

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
