require 'RMagick'

baseimg = Magick::Image.read("Miller_Gary1.JPG") {self.format = "GIF"}
baseimg = baseimg.first

img = baseimg.change_geometry('640x480') { |cols, rows, img|
  img.resize!(cols,rows)
}
img.write("large.jpg")

img = baseimg.change_geometry('320x240') { |cols, rows, img|
  img.resize!(cols,rows)
}
img.write("medium.jpg")

img = baseimg.change_geometry('75x75') { |cols, rows, img|
  img.resize!(cols,rows)
}

w = img.columns
h = img.rows
pixels = img.export_pixels(0,0,w,h, "RGB")

img = Magick::Image.new(75,75)

img.import_pixels((75-w)/2,(75-h)/2,w,h,"RGB",pixels)

img.write("small.jpg")

