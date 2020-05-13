require_relative 'img_service'
require_relative 'detection'

srvc = ImageService.new

800.times do |time|
    puts time
    begin
        @images = srvc.random_image()
        (@images["Detections"]["Scenes"] || []).each do |scene|
            moji = Detection.new(scene)
            if moji.emoji != nil
                File.write("common_emoji.txt",  moji.emoji, mode: "a")
            end
        end
        (@images["Detections"]["Objects"] || []).each do |scene|
            moji = Detection.new(scene)
            if moji.emoji != nil
                File.write("sorted_common_emoji.txt",  moji.emoji, mode: "a")
            end
        end
    rescue  => e
        puts e.inspect
    end
end