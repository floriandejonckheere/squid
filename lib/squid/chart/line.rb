require 'squid/chart/base'

module Squid
  module Chart
    # Adds a line chart to the graph.
    class Line < Base
    private
      # Draws a single line to represent the distance between two values of
      # a series in the chart.
      def draw_element(h, x, width, options = {})
        return unless previous_value = options[:previous_value]
        with cap_style: :round, line_width: @settings[:line_width] do
          line [x - width/2, h(previous_value) + zero_y], [x + width/2, h + zero_y]
        end
      end
    end
  end
end