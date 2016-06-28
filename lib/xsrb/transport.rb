module XenStore
  # Module to hold various types of Transport which allow communication
  # with XenStore in various ways.
  module Transport
    # Superclass for various types of Transport which communicate with
    # XenStore in various ways.
    class Transport
    end

    class XenBusTranspoort
    end

    class UnixSocketTransport
    end
  end
end
