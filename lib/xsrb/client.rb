module XenStore
  # Client provides high-level interaction with XenStore
  class Client
    def initialize(transport = nil)
      @transport = transport || XenStore::Connection::UnixSocketConnection.new
    end
  end
end
