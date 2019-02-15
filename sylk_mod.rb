#!/usr/bin/ruby

require 'pp'

input_f = ARGV.shift
output_f = ARGV.shift

row_index = '1'
# colm_index = 0

row_data_hash = {}
all_data_ary = []

# LibreOffice の Calc で書き出したSYLK
# C;X2;Y37;K34;EB36+1
# C;X3;Y37;K"宿町"
# C;X4;Y37;K"021"
# C;X5;Y37;K"2124514"
# C;X6;Y37;K"氏名"
# C;X7;Y37;K3394;EL$3
# C;X9;Y37;K"ヤマガタ"

# /C;X([0-9]+);Y([0-9]+);K([0-9]+|\"[^\"]*\")(;E(.+))?/

def sylk_2_hash(str)
    if /C;X([0-9]+);Y([0-9]+);K([0-9]+|\"[^\"]*\")(;E(.+))?/.match(str)
        return {:row => $2, :colm => $1, :exp => $3, :ref => $5}
    else
        return nil
    end
end

def hash_2_colm(colm_hash)
    result = "C;X#{colm_hash[:colm]};Y#{colm_hash[:row]};K#{colm_hash[:exp]}"
    if colm_hash[:ref] != nil
        result = result + ";E#{colm_hash[:ref]}"
    end
    return result
end

File.open(input_f, 'r') do |f|
    f.each_line do |cell|
        tmp_result = sylk_2_hash(cell)
        if tmp_result
            # Y(行)が変わったら
            if row_index != tmp_result[:row]
                # 前の行をまとめて最終データに追加
                all_data_ary << row_data_hash
                # 行が変わるから，行のデータは空っぽに
                row_data_hash = {}
                # 行番号も更新
                row_index = tmp_result[:row]
            end
            # 同じ行で列の追加なら，セルの情報を列番号をキーにして行データに追加
            row_data_hash[tmp_result[:colm]] = tmp_result
        else
            # 前の行までのデータがあれば，最終データに追加
            if row_data_hash.size > 0
                all_data_ary << row_data_hash
            end
            all_data_ary << cell
        end
    end
end

# pp all_data_ary
# exit


all_data_ary.each do |row|
    if row.is_a?(Hash)
        # 山新の L3 を L$3 に（行固定）
        if row['7'] != nil && /.*L([0-9]+).*/.match(row['7'][:ref])
            row['7'][:ref].gsub!(/L([0-9]+)/) {'L$'+$1}
        end
        # 読売新聞，購読料値上げ
        if row['9'] != nil && /.*ヨミ.*/.match(row['9'][:exp])
            row['7'][:ref].sub!(/L\$?8/, 'L$7')
        end
        row.each do |key,colm|
            puts hash_2_colm(colm)
        end
    elsif row.is_a?(String)
        puts row
    end
end

=begin
{
    "2"=>{:row=>"188", :colm=>"2", :exp=>"185", :ref=>"B187+1"},
    "3"=>{:row=>"188", :colm=>"3", :exp=>"\"横町２\"", :ref=>nil},
    "4"=>{:row=>"188", :colm=>"4", :exp=>"\"021\"", :ref=>nil},
    "5"=>{:row=>"188", :colm=>"5", :exp=>"\"2118816\"", :ref=>nil},
    "6"=>{:row=>"188", :colm=>"6", :exp=>"\"村上　泰夫\"", :ref=>nil},
    "7"=>{:row=>"188", :colm=>"7", :exp=>"3093", :ref=>"L$8"},
    "9"=>{:row=>"188", :colm=>"9", :exp=>"\"アサヒ\"", :ref=>nil}
}
=end