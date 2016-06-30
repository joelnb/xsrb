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
      @payload  = payload.to_s + XenStore::NUL
    end

    # Convert to a binary representation for transport to the xenstored
    #
    # @return [String] A binary version of the +Packet+.
    def pack
      packdata = [@op, @rq_id, @tx_id, @payload.length]
      packdata.pack('IIII') + @payload
    end

    class << self
      # Get size of each packet header
      #
      # @return [Integer] The size in bytes of each Packet header.
      def header_size
        4 * (32 / 8)
      end
    end
  end
end
