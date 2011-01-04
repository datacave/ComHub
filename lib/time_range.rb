# From here: http://rubyquiz.com/quiz144.html

require 'time'

class TimeSlot
  def initialize(s)
    @day_of_week = []
    @hour = []
    s.strip.split(" ").each do |range|
      if (match = range.match(/(\d{4})-(\d{4})/))
        @hour << (match[1].to_i...match[2].to_i)
      elsif (match = range.match(/([a-zA-Z]{3})-([a-zA-Z]{3})/))
        first = Time::RFC2822_DAY_NAME.index(match[1])
        second = Time::RFC2822_DAY_NAME.index(match[2])
        if (first < second)
          @day_of_week << (first..second)
        else
          @day_of_week << (first..(Time::RFC2822_DAY_NAME.size-1))
          @day_of_week << (0..second)
        end
      else
        @day_of_week << (Time::RFC2822_DAY_NAME.index(range)..Time::RFC2822_DAY_NAME.index(range))
      end
    end
  end

  def include?(time)
    dow = time.wday
    hour = time.strftime("%H%M").to_i
    any?(@day_of_week, dow) and any?(@hour, hour)
  end

  def any?(enum, value)
    return true if enum.empty?
    enum.any?{|x| x.include?(value)}
  end
end

class TimeRange
  def initialize(s)
    @ranges = []
    s.split(";").each do |part|
      @ranges << TimeSlot.new(part)
    end
  end

  def include?(time)
    return true if @ranges.empty?
    @ranges.any? {|x| x.include?(time)}
  end
end
