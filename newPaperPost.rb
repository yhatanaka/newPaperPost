#!/usr/bin/ruby
require 'pp'
src_txt = ARGV.shift

# -----------------------------------------------------------------------------------------------------------
# No. コード１，コード２       支払人カナ名称                        新規・変更区分
#     支払人漢字名称
#     金融機関                 記号                    預金種目      番号                               金額
#-----------------------------------------------------------------------------------------------------------
#   1 00000000000000000000     ｱｶﾂｶ ｵｻﾑ                              その他
#       
#     9900  ﾕｳﾁﾖｷﾞﾝｺｳ          18520                                 06451461                          3,093
#-----------------------------------------------------------------------------------------------------------
#   2                          ｱﾍﾞ ｴｲｿﾞｳ                             その他
#     阿部　榮三 
#     9900  ﾕｳﾁﾖｷﾞﾝｺｳ          18530                                 00417071                          3,394

# -------(略) と10個以上続く行
    postSep = /^-{10,}\n/ 
# スペース何個か + No. + (コード1,コード2) + 支払人カナ名称
    format_1 = /^\s+([0-9]+)\s[ 0-9]{20}\s{5}([ｧ-ﾝﾞﾟ ]+).+$/
    format_2 = //
    format_3 = //

# 1行目 連番，契約者半角カナ
    serial_No = 0
    person_kana = ""


begin
  File.open(src_txt) do |file|

# -------(略) と10個以上続く行を区切りに
    file.read.split(postSep).each do |entry|
# format_1(つまり1行目のフォーマット) に合うか
        match_1 = entry.match(format_1)
        if (match_1 && match_1[1].to_i == serial_No + 1)
                serial_No = match_1[1].to_i
                person_kana = match_1[2]
        end #if
    end #each
  end #pen

# 例外は小さい単位で捕捉する
rescue SystemCallError => e
  puts %Q(class=[#{e.class}] message=[#{e.message}])
rescue IOError => e
  puts %Q(class=[#{e.class}] message=[#{e.message}])
end