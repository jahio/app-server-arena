class Chef
  class Recipe
    # On Linux, the "file" /proc/cpuinfo contains lots of useful information
    # about the CPU on the machine. Can't speak for BSD or other *nix platforms;
    # probably has something similar but not sure what that'd be there.
    def get_cpu_count
      cpuinfo = File.read("/proc/cpuinfo")
      num_cores = cpuinfo.scan(/processor\s+:\s+\d\s/).size
      
      # safety check - return num_cores or 1 if count == zero for whatever reason
      # since we know we'll always have at least one CPU core (how could we not?)
      return (num_cores > 0 ? num_cores : 1) 
    end
  end
end