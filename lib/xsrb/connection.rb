require 'xsrb/exceptions'
require 'xsrb/utils'

module XenStore
  # Generic class which implements a connection to a XenStore daemon.
  class Connection
    # Serialize a +Packet+ and send over the wire to XenStored
    def send(pkt)
    end

    # Receive a +Packet+ from XenStored
    def recv
    end
  end
end
