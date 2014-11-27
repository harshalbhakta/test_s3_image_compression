## Overview

Download image from S3, save a copy as jpg and generate a thumbnail.

## Steps

$ ruby s3_compress "file_path_on_s3"

file_path_on_s3 example: uploads/items/1.png

## Output

Downloaded file & compressed jpg files will be available in the outputs folder for further analysis. Try different values for self.quality on line 25 & 31 to find the best options.
