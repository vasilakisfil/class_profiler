require "class_profiler"

class ClassProfiler::Benchmark
  include Singleton

  def initialize(options = {})
    @options = options
    @sum_hash = {}
    @active_labels = []
  end

  def start(label, &block)
    append_active_label(label)

    value = nil
    time = ::Benchmark.measure {
      value = block.call
    }.real

    sum_hash[label] = {num: 0, sum: 0} if sum_hash[label].nil?
    sum_hash[label][:num] += 1
    sum_hash[label][:sum] += time.round(5)

    remove_active_label(label)
    return value
  end

  def start_and_report(label = 'Total Time', &block)
    start(label, &block)

    report(label)
  end

  def report(total_label = nil)
    printf "######### Performance Report #########\n"
    if sum_hash[total_label]
      total_time = sum_hash[total_label][:sum].round(5)
      puts total_time
      sum_hash.sort_by{|label, values| values[:sum]}.to_h.each{|label, values|
        printf "%-150s %s (%s)\n", "#{label} (total time):", values[:sum].round(5), "#{((values[:sum]/ total_time) * 100).round(1)}%"
        printf "%-150s %s\n", "#{label} (number of calls):", values[:num]
        printf "%-150s %s\n\n", "#{label} (average time):", (values[:sum]/values[:num]).round(5)
      }
    end
    printf "\n######### (most time consuming method is at the bottom) #########"

    reset!
  end

  def reset!
    self.sum_hash = {}
  end

  def active?
    active_labels.any?
  end

  private
    attr_accessor :sum_hash, :options, :active_labels
    def append_active_label(label)
      active_labels << label
    end

    def remove_active_label(label)
      self.active_labels = active_labels.select{|i| i != label}
    end
end
