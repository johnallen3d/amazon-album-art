require 'helper'

class TestAmazonAlbumArt < Test::Unit::TestCase
  context "amazon-album-art module" do
      should "create a new client" do
        c = AmazonAlbumArt.new(api_key, secret_key)
        assert_equal AmazonAlbumArt::Client, c.class
      end
    end
    context "using the amazon-amazon-art client" do
      setup do
        @client = AmazonAlbumArt.new(api_key, secret_key)
      end
      context "search for known items" do
        context "and for all images sizes" do
          setup do
            @result = @client.search("phish", "rift")
          end
          should "return a hash" do
            assert_kind_of Hash, @result
          end
          should "include the found artists name" do
            assert_equal "Phish", @result[:artist]
          end
          should "include the found artists name" do
            assert_equal "Rift", @result[:album]
          end
          should "include an images key" do
            assert @result.has_key?(:images)
          end
          setup do
            @images = @result[:images]
          end
          should "include include all image sizes" do
            [:swatch, :small, :thumbnail, :tiny, :medium, :large].each do |key|
              assert @images.has_key?(key)
            end
          end
        end
        context "and just a medium search" do
          setup do
            @result = @client.search("phish", "rift", [:medium])
          end
          context "just a medium image" do
            should "include a medium image url" do
              assert_equal "http://ecx.images-amazon.com/images/I/511RmbQV7dL._SL160_.jpg", @result[:images][:medium]
            end
          end
        end
        context "no search values" do
          should "raise an ArgumentError" do
            assert_raise ArgumentError do
              @client.search
            end
          end
        end
      end
    end
    context "no keys" do
      should "raise an ArgumentError" do
        assert_raise ArgumentError do
          AmazonAlbumArt.new
        end
      end
    end
end
