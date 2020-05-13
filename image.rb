require 'httparty'
require 'json'
require_relative 'detection'

class Image
    attr_accessor :url, :emojis
    def add_emoji(moji)
        if @emojis
            @emojis.add(moji)
        else
            @emojis = Set.new
            @emojis.add(moji)
        end
    end
end

class ImageService
    def initialize
        @api_url =  "http://be.#{ENV["ECS_APP_DISCOVERY_ENDPOINT"]}:8080/"
    end

    def image
        response = HTTParty.get(@api_url)
        description = JSON.parse(response.body)
        #value = '{"ImageURL":"https://images.pexels.com/photos/1755385/pexels-photo-1755385.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940","Detections":{"Scenes":[{"Name":"Sitting","Probability":99.60382080078125,"OtherDescriptions":["Person"]},{"Name":"Human","Probability":99.60382080078125,"OtherDescriptions":null},{"Name":"Footwear","Probability":99.20458221435547,"OtherDescriptions":["Clothing"]},{"Name":"Apparel","Probability":99.20458221435547,"OtherDescriptions":null},{"Name":"Clothing","Probability":99.20458221435547,"OtherDescriptions":null},{"Name":"Nature","Probability":96.32042694091797,"OtherDescriptions":null},{"Name":"Smoke","Probability":93.261962890625,"OtherDescriptions":null},{"Name":"Fog","Probability":83.93405151367188,"OtherDescriptions":["Nature"]},{"Name":"City","Probability":81.03128051757812,"OtherDescriptions":["Urban","Building"]},{"Name":"Metropolis","Probability":81.03128051757812,"OtherDescriptions":["Urban","Building","City"]},{"Name":"Urban","Probability":81.03128051757812,"OtherDescriptions":null},{"Name":"Building","Probability":81.03128051757812,"OtherDescriptions":null},{"Name":"Town","Probability":81.03128051757812,"OtherDescriptions":["Urban","Building"]},{"Name":"Female","Probability":79.07379150390625,"OtherDescriptions":["Person"]},{"Name":"Outdoors","Probability":76.88349914550781,"OtherDescriptions":null},{"Name":"Smog","Probability":66.20036315917969,"OtherDescriptions":["Smoke","Fog","Nature"]},{"Name":"Woman","Probability":66.13030242919922,"OtherDescriptions":["Female","Person"]},{"Name":"Architecture","Probability":64.99483489990234,"OtherDescriptions":["Building"]},{"Name":"Face","Probability":59.78306579589844,"OtherDescriptions":["Person"]},{"Name":"High Rise","Probability":58.9331169128418,"OtherDescriptions":["Urban","Building","City"]},{"Name":"Pollution","Probability":55.14079666137695,"OtherDescriptions":null}],"Objects":[{"Name":"Person","Probability":99.60382080078125,"OtherDescriptions":null,"Locations":[{"Width":0.5033451914787292,"Height":0.2864053249359131,"Left":0.2780051529407501,"Top":0.4839746952056885}]},{"Name":"Shoe","Probability":99.20458221435547,"OtherDescriptions":["Footwear","Clothing"],"Locations":[{"Width":0.1222723051905632,"Height":0.04674006626009941,"Left":0.2548677921295166,"Top":0.7200642824172974},{"Width":0.15012022852897644,"Height":0.03797006607055664,"Left":0.46840140223503113,"Top":0.7341600060462952}]}]}}'
        #description = JSON.parse(value)

        img = Image.new
        img.url = description["ImageURL"]

        (description["Detections"]["Scenes"] || []).each do |scene|
            moji = Detection.new(scene)
            if moji.emoji != nil
                img.add_emoji(moji.emoji)
            end
        end

        (description["Detections"]["Objects"] || []).each do |obj|
            moji = Detection.new(obj)
            if moji.emoji != nil
                img.add_emoji(moji.emoji)
            end
        end

        return img
    end

end
