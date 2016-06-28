module XenStore
  module Exceptions
    class XenStoreException < StandardError
    end

    class InvalidPermission < XenStoreException
    end

    class InvalidPath < XenStoreException
    end

    class InvalidPayload < XenStoreException
    end

    class InvalidOperation < XenStoreException
    end
  end
end
