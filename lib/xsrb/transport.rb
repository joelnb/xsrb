require 'socket'

module XenStore
  # Module to hold various types of Transport which allow communication
  # with XenStore in various ways.
  module Transport
    # A Transport implementation which communicates with XenStore over the
    # special device on UNIX-like operating systems.
    class XenBusTranspoort
      def initialize(path = nil)
        path ||= XenStore::Utils.xenbus_path
        @fileno = File.open(path, 'w')

        ObjectSpace.define_finalizer(self, proc { @fileno.close })
      end

      def send(s)
      end

      def recv
      end

      def close
        @fileno.close
      end
    end

    # A Transport implementation which communicates with XenStore over a
    # UNIX socket.
    class UnixSocketTransport
      def initialize(path = nil)
        path ||= XenStore::Utils.unix_socket_path
        @sock = UNIXSocket.new path

        ObjectSpace.define_finalizer(self, proc { @sock.close })
      end

      def send(s)
      end

      def recv
      end

      def close
        @sock.close
      end
    end
  end
end
