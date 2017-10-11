function resize-images -d "resize images with convert"
  for f in $argv
    echo "convert $f" 
    convert $f -resize 1024 r-$f 
  end
end

