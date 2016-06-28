module XenStore
  # An individual Packet of data sent to XenStore.
  class Packet
    def initialize(op, payload, rq_id, tx_id = 0)
      l = payload.length
      raise XenStore::Exceptions::InvalidPayload,
            "Payload too large (#{l}): #{payload}" if l > 4096

      if op.is_a? Symbol
        raise XenStore::Exceptions::InvalidOperation,
              op.to_s unless XenStore::OPERATIONS.key?(op)
        @op = XenStore::OPERATIONS[op]
      else
        raise XenStore::Exceptions::InvalidOperation,
              op.to_s unless XenStore::OPERATIONS.values.include?(op)
        @op = op
      end

      @rq_id    = rq_id
      @tx_id    = tx_id
      @payload  = payload
    end

    def pack
      packdata = [@op, @rq_id, @tx_id, @payload.length]
      packdata.pack('IIII') + @payload.to_s
    end

    class << self
      def unpack(header, payload)
        # Ignore length
        op, rq_id, tx_id = header.unpack('IIII')
        new(op, payload, rq_id, tx_id)
      end
    end
  end
end
