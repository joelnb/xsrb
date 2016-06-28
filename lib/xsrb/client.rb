module XenStore
  # Client provides high-level interaction with XenStore
  class Client
    begin
      DOM0 = File.open('/proc/xen/capabilities', 'rb', &:read) == "control_d\n"
    rescue Errno::ENOENT
      DOM0 = false
    end
  end
end
