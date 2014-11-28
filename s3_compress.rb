require 'aws-sdk'
require 'RMagick'
require 'pathname'

# s3_image_path: 'uploads/images/1.png'
def compress_and_generate_thumb(s3_image_path, max_width, max_height, thumb_max_width, thumb_max_height)

  s3 = AWS::S3.new :access_key_id => ENV["AWS_ACCESS_KEY_ID"], :secret_access_key => ENV["AWS_SECRET_KEY"]
  bucket = s3.buckets['learnapt-dev'] # no request made
  s3_image_pathname = Pathname.new(s3_image_path) 
  obj = bucket.objects[s3_image_pathname.to_s] # makes no request, returns an AWS::S3::S3Object

  image_path = File.expand_path("./output/" + s3_image_pathname.basename.to_s)
  thumb_path = File.expand_path("./output/thumb_" + s3_image_pathname.basename.to_s)

  # streaming download from S3 to a file on disk
  File.open(image_path, 'w+') do |file|
    obj.read do |chunk|
       file.write(chunk)
    end
  end

  # Read first image from file
  image = Magick::Image::read(image_path).first

  image.format = 'JPEG'

  image.write(image_path.gsub("png","jpg")) # { self.quality = ARGV[1].to_i }

  # Resize image to maxium dimensions
  image.resize_to_fit!(250)

  # Write image to file system
  image.write(thumb_path.gsub("png","jpg")) # { self.quality = ARGV[1].to_i }

  # Free image from memory
  image.destroy!

end

compress_and_generate_thumb(ARGV[0].to_s, 800, 800, 250, 250)