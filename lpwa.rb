# coding: utf-8
#
# LPWAモジュールのデータをHTTPサーバへ送る
#
require 'serialport'
require 'net/http'
require 'uri'

require './config.rb'

def send_command(sp, cmd)
  cmd += "\r"
  cmd.split("").each do |c|
    sp.putc c
    sp.getc
  end
  sp.getc
end

def receive_data(sp)
  sp.gets
  sp.gets.chomp
end


#
# ここからが mainの処理
# HTTPサーバの状態を確認する
status = nil
begin
  status = Net::HTTP.get(URI.parse($server_url))
rescue => e
  puts "Error: Internet connection"
  sleep 5
  retry
end
  
unless status then
  puts "server not found"
  exit
end

# シリアルポートを開く
begin
  sp = SerialPort.new($serial_port, $serial_bps , 8, 1)
rescue => e
  puts "Error: Serial connection"
  sleep 5
  retry
end

# ATコマンドでLPWAモジュールの接続確認
loop do
  send_command(sp, "AT")
  break if receive_data(sp) =~ /OK/
end

# ID取得
send_command(sp, "AT/ID")
device_id = receive_data(sp)
puts "DeviceID is #{device_id}."

unless device_id =~ /^..0000/ then
  puts "LPWA module is NOT HQ."
end

# HTTPサーバへLPWAのIDを送る
Net::HTTP.post_form(URI.parse($server_url+"lpwa/register_id"),
                    {'device_id'=>device_id})

# ここからがメインループ
loop do
  # LPWAモジュールからメッセージを受信する
  # メッセージがあれば、それをサーバへ送信する
  send_command(sp, "ATG")
  msg = receive_data(sp)
  if msg!="0" then
    begin
      # メッセージをHTTPサーバへ送る
      Net::HTTP.post_form(URI.parse($server_url+"lpwa/store_packet"),
                          {'data'=>msg, 'area'=>$lpwa_area_name})
      puts msg
    rescue => e
      puts "Retry"
      sleep 5
      retry
    end
  end
  # サーバのキューからメッセージを受け取る
  # メッセージがあれば、それをLPWAモジュールのコマンドとして実行する
  begin
    response = Net::HTTP.get(URI.parse($server_url+"lpwa/get_message/#{$lpwa_area_name}"))
  rescue => e
    puts "Retry"
    sleep $api_access_cycle * 5
    retry
  end
  if response != "0" then
    send_command(sp, response)
    msg = receive_data(sp)  # OKが返る
  end
  sleep $api_access_cycle
end


