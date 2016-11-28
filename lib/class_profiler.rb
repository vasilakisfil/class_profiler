require "class_profiler/version"

$sum = 0
$sum_hash = {}
def bench!(label, &block)
  value = nil
  time = Benchmark.measure {
    value = block.call
  }.real

  $sum_hash[label] = {num: 0, sum: 0} if $sum_hash[label].nil?
  $sum_hash[label][:num] += 1
  $sum_hash[label][:sum] += time.round(5)

  return value
end

def report!
  puts "######### Performance Report #########"
  puts
  $sum_hash.sort_by{|label, values| values[:sum]}.to_h.each{|label, values|
    printf "%-150s %s\n", "#{label} (total time):", values[:sum].round(5)
    printf "%-150s %s\n", "#{label} (number of calls):", values[:num]
    printf "%-150s %s\n", "#{label} (average time):", (values[:sum]/values[:num]).round(5)
    puts
  }
  puts
  puts "######### (most time consuming method is at the bottom) #########"
end

class Object
  def label(method_name, notes = nil)
    if notes
    "#{self.class.name}##{method_name} (#{notes})"
    else
    "#{self.class.name}##{method_name}"
    end
  end
end

def reset!
  $sum_hash = {}
  $sum = 0
  $total = 0
end

$total = 0

def reset_total!
  $total = 0
end

module ClassProfiler
  CONSTANTIZE = ->(string) {
    string.split(':').select{|i|
      !i.blank? && i.downcase != '<class' && !i.start_with?('0x')
    }.map{|i|
      i.gsub("#","").gsub("<","").gsub(">","")
    }.join("::").constantize #use const_get
  }

  #add some metaprogramming here
  IGNORED_METHODS = [Object, BasicObject, Class, Class.new, Module].map{|o|
    array = []
    [:private_instance_methods, :protected_instance_methods, :instance_methods].each do |m|
      array.concat(o.send(m, true))
    end

    [:private_methods, :protected_methods, :methods].each do |m|
      array.concat(o.send(m, true))
    end
    array
  }.flatten.uniq - [:initialize]

  def self.for(options = {})
    methods = options[:instance_methods] || []
    _caller = CONSTANTIZE.call(caller_locations(1,1)[0].label)

    if options[:modules]
      methods.concat(
        options[:modules].map{|m|
          _get_methods_for(m)
        }
      )
    end

    @__cp_instance_methods = methods.flatten.uniq

    return self
  end

  def self.included(base)
    @__cp_instance_methods = _get_methods_for(base, true) if @__cp_instance_methods.nil?

    default_protected_methods = self.protected_instance_methods
    default_private_methods = self.private_instance_methods

    (@__cp_instance_methods).each do |method_name|
      base.send(:alias_method, "__#{method_name}", method_name)

      base.send(:define_method, method_name) do |*args, &block|
        bench!(label(__method__)){
          if block
            self.send("__#{method_name}", *args) { block.call }
          else
            self.send("__#{method_name}", *args)
          end
        }
      end

      protected(method_name) if default_protected_methods.include?(method_name)
      private(method_name) if default_private_methods.include?(method_name)
    end

    @__cp_instance_methods = nil
  end

  def self._get_methods_for(_caller, inherited = false)
    _caller.constantize if _caller.is_a? String #use const_get

    array = []
    array.concat(
      _caller.instance_methods(inherited)
    ).concat(
      _caller.protected_instance_methods(inherited)
    ).concat(
      _caller.private_instance_methods(inherited)
    )

    return array unless inherited
    return (array - IGNORED_METHODS).flatten.uniq
  end
end
