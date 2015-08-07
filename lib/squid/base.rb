require 'squid/settings'

module Squid
  # Abstract class that delegates unhandled calls to a +pdf+ object which
  # is convenient when working with Prawn methods
  class Base
    extend Settings
    include ActiveSupport::NumberHelper

    attr_reader :pdf, :data

    def initialize(document, data = {}, settings = {})
      @pdf = document
      @data = data
      @settings = settings
    end

    # Delegates all unhandled calls to object returned by +pdf+ method.
    def method_missing(method, *args, &block)
      return super unless pdf.respond_to?(method)
      pdf.send method, *args, &block
    end

  private

    # Convenience method to wrap a block by setting and unsetting a Prawn
    # property such as line_width.
    def with(new_values = {})
      old_values = Hash[new_values.map{|k,_| [k,self.public_send(k)]}]
      new_values.each{|k, new_value| public_send "#{k}=", new_value }
      stroke { yield }
      old_values.each{|k, old_value| public_send "#{k}=", old_value }
    end

    # Returns the formatted value (currency, percentage, ...).
    def format_for(value, format)
      case format
      when :percentage then number_to_percentage value, precision: 1
      when :currency then number_to_currency value
      when :seconds then number_to_minutes_and_seconds value
      when :float then number_to_delimited value
      else number_to_delimited value.to_i
      end.to_s
    end

    def number_to_minutes_and_seconds(value)
      "#{value.round / 60}:#{(value.round % 60).to_s.rjust 2, '0'}"
    end

    # Default options for text elements (labels, categories, ...)
    def text_options
      {valign: :center, overflow: :shrink_to_fit}
    end

    def legend_height
      15
    end

    # Default font size for text elements (labels, categories, ...)
    def font_size
      8
    end

    # Default height for text elements (labels, categories, ...)
    def text_height
      (font_size + 2) * 2
    end

    # Default horizontal padding between elements
    def padding
      5
    end
  end
end
