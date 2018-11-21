#!/usr/bin/ruby
require 'pp'
require 'nkf'
require 'csv'

src_txt = ARGV.shift
result_csv = ARGV.shift

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
    format_1 = /^\s+([0-9]+)\s[ 0-9]{20}\s{5}([ｧ-ﾝﾞﾟ]+\s?[ｧ-ﾝﾞﾟ]+).+$/
    format_2 = /\s+(\S+\s*\S+)\s*$/
    format_3 = /^\s+.[0-9]+\s+[ｧ-ﾝﾞﾟ]+\s+([0-9]+)\s+([0-9]+)\s+([0-9,]+)/

# 1行目 連番，契約者半角カナ
    serial_No = 0
    result_ary =[['No.', '支払人カナ名称', '支払人漢字名称', '預金種目', '口座番号', '金額']]

begin
  File.open(src_txt) do |file|

# -------(略) と10個以上続く行を区切りに
    file.read.split(postSep).each do |entry|
# format_1(つまり1行目のフォーマット) に合うか
        match_1 = entry.match(format_1)
        if (match_1 && match_1[1].to_i == serial_No + 1)
                serial_No = match_1[1].to_i
# 半角カナ → 全角カナ
                person_kana = NKF.nkf("-Xw", match_1[2])
# entry を改行で4行に分ける
                entry_ary = entry.split("\n")
# format_2(2行目のフォーマット)に合うか
                match_2 = entry_ary[1].match(format_2)
                if (match_2)
                        person_kanji = match_2[1].to_s
                end
                match_3 = entry_ary[2].match(format_3)
                if (match_3)
                        kouza_type = match_3[1]
                        kouza_No = match_3[2]
                        paement = match_3[3]
                end

#                puts [serial_No, person_kana, person_kanji, kouza_type, kouza_No, paement].join(',')
                result_ary.push( [serial_No, person_kana, person_kanji, kouza_type, kouza_No, paement] )
        end #if
    end #each
  end #pen

output_option = {}
CSV.open(result_csv,"wb", output_option) do |outputCSV|
	result_ary.each do |eachRow|
		outputCSV << eachRow
	end #each
end #

# 例外は小さい単位で捕捉する
rescue SystemCallError => e
  puts %Q(class=[#{e.class}] message=[#{e.message}])
rescue IOError => e
  puts %Q(class=[#{e.class}] message=[#{e.message}])
end