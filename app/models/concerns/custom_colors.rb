# manages custom_colors field
module CustomColors
  extend ActiveSupport::Concern

  included do
    DEFAULT_COLORS = {
      unpaid: '#f44336',
      paid: '#4caf50',
      semi_paid: '#f8ac59',
      membership: nil,
      reselling: nil,
      invoiced: nil,
      other: '#eeeeee',
    }.freeze

    store :custom_colors, coder: Hash

    def custom_colors
      DEFAULT_COLORS.map do |type, color|
        [type, self[:custom_colors][type].blank? ? color : self[:custom_colors][type]]
      end.to_h
    end

    def custom_colors=(colors)
      colors.to_h.each do |type, color|
        type = type.to_s.strip.to_sym

        if DEFAULT_COLORS.keys.include?(type)
          color = color.to_s.strip
          if color.blank? || color == "#000000"
            self[:custom_colors][type] = nil
          else
            self[:custom_colors][type] = color.to_s.strip
          end
        end
      end

      self[:custom_colors]
    end
  end
end
