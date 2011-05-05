require 'nokogiri'
require 'sucker'

module AmazonAlbumArt

  def self.new(access_key, secret_key, locale = "us")
    Client.new(access_key, secret_key, locale)
  end

  class Client

    def initialize(access_key, secret_key, locale)
      raise ArgumentError.new("An access and secret key are require") if access_key.empty? || secret_key.empty?
      
      @worker = Sucker.new(
        :locale => "us",
        :key    => access_key, 
        :secret => secret_key
      )
    end

    def search(artist, album, sizes = [:swatch, :small, :thumbnail, :tiny, :medium, :large])
      raise ArgumentError.new("An artist and album are required to search") if artist.empty? || album.empty?

      # clean up params, this client may be used repeatedly
      clean_params(%w{IdType ResponseGroup ItemId})

      # Prepare a request.
      @worker << {
        "Operation"     => "ItemSearch",
        "SearchIndex"   => "Music",
        "Title"         => album,
        "Artist"        => artist
      }

      # Get a response.
      results = @worker.get

      # Make sure nothing went awry.
      return nil if !check_response?(results, "Error finding album")

      # Now parse it.
      results.map("Item") do |match|
        begin
          attribs = match['ItemAttributes']
          puts attribs
          # grab values that were returned
          found_artist, found_album = load_artist(attribs), load_album(attribs)
        rescue StandardError => bang
          # handled error from Sucker in some cases
          next
        end
        # check to see if we have a reasonable match
        next unless !found_album.empty? && !found_artist.empty? && matches?(album, found_album) && matches?(artist, found_artist)

        # remove params not used for image search
        # @worker.parameters.delete_if { |k,v| %w{SearchIndex Title Artist}.include? k }
        clean_params(%w{SearchIndex Title Artist})

        # fetch images
        @worker << {
          "Operation"     => "ItemLookup",
          "IdType"        => "ASIN",
          "ResponseGroup" => "Images",
          "ItemId"        => match["ASIN"]
        }

        # Get a response.
        images = @worker.get

        # Make sure nothing went awry.
        return nil if !check_response?(results, "Error finding images")

        # parse response
        doc = Nokogiri::XML.parse(images.body)

        return { :artist => found_artist, :album => found_album, :images => load_images(doc, sizes) }
      end
      
      return nil # nothing found
    end

  private
    def matches?(s1, s2, tolerance = 2)
      s1 == s2 ||
      s1 =~ /#{Regexp.escape s2}/i ||
      s2 =~ /#{Regexp.escape s1}/i ||
      (levenshtein(s1, s2) <= tolerance)
    end

    def levenshtein(str1, str2)
      s, t = [str1.unpack('U*'), str2.unpack('U*')]
      n, m = [s.length, t.length]
      return m if (0 == n)
      return n if (0 == m)
      d = (0..m).to_a
      x = nil
      (0...n).each do |i|
          e = i+1
          (0...m).each do |j|
              cost = (s[i] == t[j]) ? 0 : 1
              x = [d[j+1] + 1, e + 1, d[j] + cost].min
              d[j] = e
              e = x
          end
          d[m] = x
      end
      return x
    end
    
    def clean_params(params)
      # remove given params so worker can be reused
      @worker.parameters.delete_if { |k,v| params.include? k }
    end
    
    def load_artist(attribs)
      # found artists are returned in many different permutations  
      return attribs['Artist'].first if attribs.has_key?('Artist') && attribs['Artist'].is_a?(Array)
      return attribs['Artist'] if attribs.has_key?('Artist')
      return attribs['Author'] if attribs.has_key?('Author')
      return attribs['Creator'].map { |item| item["__content__"] if item.has_key?("__content__") }.join(" and ") if attribs.has_key?("Creator") && attribs['Creator'].is_a?(Array)
      return attribs["Creator"]["__content__"] if attribs.has_key?("Creator") && attribs["Creator"].has_key?('__content__')
      return nil
    end
    
    def load_album(attribs)
      attribs.has_key?('Title') ? attribs['Title'] : ""
    end
    
    def load_images(doc, sizes)
      # build the hash with requested values
      {}.tap do |urls|
        sizes.each do |size|
          urls.merge!({ size => doc.css("Item > ImageSets > ImageSet[@Category=\"primary\"] > #{size.to_s.capitalize}Image > URL").text })
        end
      end
    end

    def check_response?(results, msg)
      begin
        return results.valid? || results.find("Error").size == 0
      rescue StandardError => bang
        # handled error from Sucker in some cases
        return false
      end
    end
  end
  
  class AmazonAlbumArtError < StandardError
    alias :msg :message
    def initialize(msg)
      super(msg)
    end
  end
end