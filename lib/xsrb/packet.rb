module XenStore
  # An individual Packet of data sent to XenStore.
  class Packet
    def initialize(op, payload, rq_id, tx_id = 0)
      if payload.length > 4096
        raise XenStore::Exceptions::InvalidPayload,
              "Payload too large (#{l}): #{payload}"
      end

      @op       = check_op op
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
      # Check if the provided operation is valid and raise a
      # +XenStore::Exceptions::InvalidOperation+ exception if not.
      #
      # @param op Should be either a symbol or a uint. If a symbol
      #           then it will be used as a key to lookup the value
      #           in the +XenStore::OPERATIONS+ hash.
      def check_op(op)
        if op.is_a? Symbol
          unless XenStore::OPERATIONS.key? op
            raise XenStore::Exceptions::InvalidOperation, op.to_s
          end

          XenStore::OPERATIONS[op]
        else
          unless XenStore::OPERATIONS.values.include? op
            raise XenStore::Exceptions::InvalidOperation, op.to_s
          end

          op
        end
      end

      # Get size of each packet header
      #
      # @return [Integer] The size in bytes of each Packet header.
      def header_size
        4 * (32 / 8)
      end
    end
  end
end
