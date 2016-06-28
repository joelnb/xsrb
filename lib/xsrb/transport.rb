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
        @file = File.open(path, 'wb')

        # Ensure the file is closed when this object is garbage collected
        ObjectSpace.define_finalizer(self, proc { @file.close })
      end

      def send(data)
        size = data.length
        # Errno::EPIPE if other end disconnects
        size -= @file.write while size
      end

      def recv(size)
        chunks = []
        while size
          chunk = @file.read(size)
          raise Errno::ECONNRESET unless chunk

          chunks << read
          size -= read.length
        end
        chunks.join ''
      end

      def close
        @file.close
      end
    end

    # A Transport implementation which communicates with XenStore over a
    # UNIX socket.
    class UnixSocketTransport
      def initialize(path = nil)
        path ||= XenStore::Utils.unix_socket_path
        @sock = UNIXSocket.new path

        # Ensure the socket is closed when this object is garbage collected
        ObjectSpace.define_finalizer(self, proc { @sock.close })
      end

      def send(data)
        @sock.write(data)
      end

      def recv(size)
        chunks = []
        while size
          chunks << @sock.read(size)
          size -= chunks[-1].length
        end
        chunks.join ''
      end

      def close
        @sock.close
      end
    end
  end
end
