require 'xsrb/exceptions'
require 'xsrb/utils'

module XenStore
  module Connection
    # Generic class which implements a connection which send Packets to a
    # XenStore daemon.
    class PacketConnection
      def initialize(transport)
        @transport = transport
      end

      # Serialize a +Packet+ and send over the wire to XenStored
      #
      # @param pkt [Packet] The +Packet+ of data to send to xenstored.
      def send(pkt)
        data = pkt.pack
        @transport.send data
      end

      # Receive a +Packet+ from XenStored
      #
      # @return [Packet] The latest packet received from XenStore.
      #                  Will block until either a packet is received
      #                  or an error occurs.
      def recv
        header = @transport.recv Packet.header_size

        op, rq_id, tx_id, len = header.unpack('IIII')
        if len > 4096
          raise XenStore::Exceptions::InvalidPayload,
                "Payload too large (#{l})"
        end

        body = @transport.recv len
        Packet.new(op, body, rq_id, tx_id)
      end
    end

    # A +PacketConnection+ implementation which communicates with XenStored over
    # a UNIX socket.
    class UnixSocketConnection < PacketConnection
      def initialize(path = nil)
        @path = path || XenStore::Utils.unix_socket_path
        transport = XenStore::Transport::UnixSocketTransport.new @path
        super(transport)
      end
    end

    # A +PacketConnection+ implementation
    class XenBusConnection < PacketConnection
      def initialize(path = nil)
        @path = path || XenStore::Utils.xenbus_path
        transport = XenStore::Transport::XenBusTransport.new @path
        super(transport)
      end
    end
  end
end
