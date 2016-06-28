require 'logging'

require 'xsrb/utils'
require 'xsrb/version'

Logging.logger.root.level = :warn

# Module XenStore implements XenStore access APIs on Ruby.
# The implementation is modelled on the pyxs python module.
module XenStore
  autoload :Client,     'xsrb/client'
  autoload :Connection, 'xsrb/connection'
  autoload :Exceptions, 'xsrb/exceptions'
  autoload :Packet,     'xsrb/packet'
  autoload :Transport,  'xsrb/transport'
end
