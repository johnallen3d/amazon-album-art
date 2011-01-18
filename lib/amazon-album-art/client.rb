require 'nokogiri'
require 'sucker'

module AmazonAlbumArt

  def self.new(access_key, secret_key, locale = "us")
    Client.new(access_key, secret_key, locale)
  end

  class Client

    def initialize(access_key, secret_key, locale)
      raise ArgumentError.new("An access and secret key are require") if access_key.blank? || secret_key.blank?
      
      @worker = Sucker.new(
        :locale => "us",
        :key    => access_key, 
        :secret => secret_key
      )
    end

    def search(artist, album, sizes = [:swatch, :small, :thumbnail, :tiny, :medium, :large])
      raise ArgumentError.new("An artist and album are required to search") if artist.blank? || album.blank?

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
      check_response(results, "Error finding album")

      # Now parse it.
      results.map("Item") do |match|
        begin
          attribs = match['ItemAttributes']
          puts attribs
          # grab values that were returned
          found_artist, found_album = (attribs['Artist'] ||= attribs['Author'] ||= (attribs.has_key?("Creator") ? attribs["Creator"]["__content__"] : "")), match['ItemAttributes']['Title']
        rescue StandardError => bang
          # getting unhandled error from Sucker in some cases
          next
        end
        # check to see if we have a reasonable match
        next unless !found_album.blank? && !found_artist.blank? && matches?(album, found_album) && matches?(artist, found_artist)

        # remove params not used for image search
        @worker.parameters.delete_if { |k,v| %w{SearchIndex Title Artist}.include? k }

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
        check_response(results, "Error finding images")

        # parse response
        doc = Nokogiri::XML.parse(images.body)

        return { :artist => found_artist, :album => found_album, :images => load_images(doc, sizes) }
      end
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
    
    def load_images(doc, sizes)
      # build the hash with requested values
      {}.tap do |urls|
        sizes.each do |size|
          urls.merge!({ size => doc.css("Item > ImageSets > ImageSet[@Category=\"primary\"] > #{size.to_s.capitalize}Image > URL").text })
        end
      end
    end

    def check_response(results, msg)
      raise AmazonAlbumArtError.new(msg) unless results.valid? || results.find("Error").size > 0
    end
  end
  
  class AmazonAlbumArtError < StandardError
    alias :msg :message
    def initialize(msg)
      super(msg)
    end
  end
end