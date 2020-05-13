require_relative 'emojis'

class Detection
    attr_reader :emoji

    def initialize(detection)
        @names = detection["OtherDescriptions"] || []
        @names.prepend detection["Name"]
        @emoji = nil
        @names.each do |name|
            @emoji = Emojify.ForName(name)
            break if @emoji != nil
        end
    end
end