require 'xsrb/exceptions'
require 'xsrb/utils'

module XenStore
  # An individual Packet of data sent to XenStore.
  class Packet
    def initialize(op, payload, rq_id, tx_id = nil)
      l = payload.length
      raise XenStore::Exceptions::InvalidPayload,
            "Payload too large (#{l}): #{payload}" if l > 4096
      raise XenStore::Exceptions::InvalidOperation,
            op.to_s unless XenStore::Utils::OPERATIONS.key? op
      puts rq_id, tx_id
    end
  end

  # Generic class which implements a connection to a XenStore daemon.
  class Connection
  end
end
