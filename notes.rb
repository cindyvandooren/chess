# [0, 1, 4, 5, 7].each do |attr|
#   puts '----------------------------------------------------------------'
#   puts "ESC[#{attr};Foreground;Background"
#   30.upto(37) do |fg|
#     40.upto(47) do |bg|
#       print "\033[#{attr};#{fg};#{bg}m #{fg};#{bg}  "
#     end
#   puts "\033[0m"
#   end
# end
######## snippet from SO ^^^ ######

# puts "Testing testing one fish two fish \033[31mRED FISH\033[34m BLUE FISH\033[0m"
# (90..97).each do |i|
#     puts "\033[#{i}m are you my orange: #{i}\033[0m"
# end
#puts "\033[93m ORANGE \033[31m vs. \033[1;33m YELLOW\033[0m"#=> same
#puts "\033[38;5;202m Orange: 202 \033[38;5;208m Orange: 208 \033[0m"#=> 208
#puts "back to normal"
# print "\033[4;48;5;016m"
# colors = { :R => 91, :G => 92, :Y => 93, :B => 94,
# 	 :P => 95, :O => "38;5;208", :GREY => "128;128;128"}
# colors.each_pair do |name, val|
#   print "\033[#{val}m #{name.to_s}  "
# end
#   puts "\033[0m"
x = 1
while x <= 256
  puts "\033[38;5;#{x}m PLEASE BE GREY\033[0m: #{x}"
  x += 1
end
## clear terminal screen with"\e[H\e[2J”
#
# require 'io/console'
#
# # Reads keypresses from the user including 2 and 3 escape character sequences.
# def read_char
#   STDIN.echo = false
#   STDIN.raw!
#
#   input = STDIN.getc.chr
#   if input == "\e" then
#     input << STDIN.read_nonblock(3) rescue nil
#     input << STDIN.read_nonblock(2) rescue nil
#   end
# ensure
#   STDIN.echo = true
#   STDIN.cooked!
#
#   return input
# end
# #
# # oringal case statement from:
# # http://www.alecjacobson.com/weblog/?p=75
# def show_single_key
#   c = read_char
#
#   case c
#   when " "
#     puts "SPACE"
#   when "\t"
#     puts "TAB"
#   when "\r"
#     puts "RETURN"
#   when "\n"
#     puts "LINE FEED"
#   when "\e"
#     puts "ESCAPE"
#   when "\e[A"
#     puts "UP ARROW"
#   when "\e[B"
#     puts "DOWN ARROW"
#   when "\e[C"
#     puts "RIGHT ARROW"
#   when "\e[D"
#     puts "LEFT ARROW"
#   when "\177"
#     puts "BACKSPACE"
#   when "\004"
#     puts "DELETE"
#   when "\e[3~"
#     puts "ALTERNATE DELETE"
#   when "\u0003"
#     puts "CONTROL-C"
#     exit 0
#   when /^.$/
#     puts "SINGLE CHAR HIT: #{c.inspect}"
#   else
#     puts "SOMETHING ELSE: #{c.inspect}"
#   end
# end
#
# show_single_key while(true)
