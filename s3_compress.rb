require 'aws-sdk'
require 'RMagick'
require 'pathname'

# s3_image_path: 'uploads/images/image_1.png'
def compress_and_generate_thumb(s3_image_path, max_width, max_height, thumb_max_width, thumb_max_height)

  bucket_name = ENV["AWS_TEST_BUCKET"]
  s3_image_folder_path = s3_image_path.gsub(File.basename(s3_image_path, "."),"") # 'uploads/images/'
  s3_image_name_without_extension = File.basename(s3_image_path, ".*") # 'image_1'

  # Local locations
  original_image_local_path = File.expand_path("./output/" + File.basename(s3_image_path)) # './output/image_1.png'
  compressed_image_local_path = File.expand_path("./output/" + s3_image_name_without_extension + "_c.jpg") # './output/image_1_c.jpg'
  thumb_image_local_path = File.expand_path("./output/" + s3_image_name_without_extension + "_t.jpg") # './output/image_1_t.jpg'

  # S3 locations
  compressed_image_s3_path = s3_image_folder_path + "compressed/" + s3_image_name_without_extension + "_c.jpg"
  thumb_image_s3_path = s3_image_folder_path + "thumb/" + s3_image_name_without_extension + "_t.jpg"

  s3 = AWS::S3.new :access_key_id => ENV["AWS_ACCESS_KEY_ID"], :secret_access_key => ENV["AWS_SECRET_KEY"]
  bucket = s3.buckets[bucket_name] # no request made
  obj = bucket.objects[s3_image_path.to_s] # makes no request, returns an AWS::S3::S3Object

  # streaming download from S3 to a file on disk
  File.open(original_image_local_path, 'w+') do |file|
    obj.read do |chunk|
       file.write(chunk)
    end
  end

  # Read first image from file
  image = Magick::Image::read(original_image_local_path).first

  image.format = 'JPEG'

  image.write(compressed_image_local_path) { self.quality = ARGV[1].to_i }

  # Resize image to maxium dimensions
  image.resize_to_fit!(250)

  # Write image to file system
  image.write(thumb_image_local_path) { self.quality = ARGV[1].to_i }

  # Free image from memory
  image.destroy!

  # Upload a compressed & thumbnail.
  puts "Uploading #{compressed_image_local_path}"
  s3.buckets[bucket_name].objects[compressed_image_s3_path].write(:file => original_image_local_path)
  puts "Uploading #{thumb_image_local_path}"
  s3.buckets[bucket_name].objects[thumb_image_s3_path].write(:file => thumb_image_local_path)

end

compress_and_generate_thumb(ARGV[0].to_s, 800, 800, 250, 250)