`mode 40, 10`

require 'Win32API'
require 'JSON'
$listener = Win32API.new('user32', 'GetAsyncKeyState', ['i'], 'i')
Thread.new {`title Lag Switch`}

puts ""
puts "-- LAG SWITCH --".center(39, " ")

def enable()
    system('netsh advfirewall firewall add rule name="LagSwitch" dir=in action=block program="' + $config["application"] + '" > nul 2>&1') if $config["mode"] == "in" or $config["mode"] == "both"
    system('netsh advfirewall firewall add rule name="LagSwitch" dir=out action=block program="' + $config["application"] + '" > nul 2>&1') if $config["mode"] == "out" or $config["mode"] == "both"
end

def disable()
    system('netsh advfirewall firewall delete rule name="LagSwitch" > nul 2>&1')
end

if !File.exist? "config.json"
	config = Hash.new
	config["application"] = "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe"
	config["key"] = '0x58'
	config["mode"] = 'both'
	File.open("config.json", 'w') { |file| file.write(JSON.pretty_generate(config).to_s) }
end

$config = JSON.parse(File.read("config.json"))

active = false
pressed = false

if defined? Ocra
  puts "Detected compression by OCRA. Terminating."
  exit
end
disable()
while true
  print "\e[1;1H"
  puts ""
  puts "-- LAG SWITCH --".center(39, " ")
  puts "".center(39, " ")
  puts "".center(39, " ")
  if active
    puts "STATUS: active".center(39, " ")
  else
    puts "STATUS: inactive".center(39, " ")
  end
  puts "".center(39, " ")
  puts "KEY: #{$config['key'].to_i(16)}".center(39)
  puts ""
  keyState = $listener.call($config['key'].to_i(16))
  if keyState != 0
    if !pressed
      active = !active
      pressed = true
      print "toggling...".center(39)
      enable() if active
      disable() if !active
      print "\r                                "
    end
  else
    pressed = false
  end

  sleep 0.05
end
