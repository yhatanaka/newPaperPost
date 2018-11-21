#!//usr/bin/ruby
require 'csv'
require 'pp'
require "nkf"

# script.rb (-fm) input.csv output => output_customer.csv, output_papers.csv
# 普通に実行するとutl-8で出力するが，「-fm」を最初につけるとShift_JISで出力
output_option = {}
if (ARGV[0] == "-fm")
	output_option = {:encoding => "Shift_JIS"}
	ARGV.shift
end

inputFile = ARGV.shift
outputFile_name = ARGV.shift

dataTable = CSV.read( inputFile, {
	headers:	true,
	encoding:	"Shift_JIS:UTF-8",
	return_headers:	true,
	skip_blanks: true,
#	, skip_lines: /^ダウンロードした時刻：.+/
} )

# CSVファイルの1行目
# 読者番号,読者名（漢字）,読者名（カナ）,郵便番号,住所,電話番号,集金区分,銀行,支店コード,支店名,口座番号,口座名義,現読区分,購読紙,部数,契約開始日,契約終了日

headers_str = <<EOS
読者番号,読者名（漢字）,読者名（カナ）,郵便番号,住所,電話番号,集金区分,銀行,支店コード,支店名,口座番号,口座名義,現読区分,購読紙,部数,契約開始日,契約終了日
EOS

# 末尾の改行削除して，配列に
headers_array = headers_str.chomp.split(',')

# np_headers_array.size => 17
# 最初の12列は購読者，残りの5列は購読紙
#customer_headers = headers_array[0..11]
#papers_headers = headers_array[12..16]

customer_array = Array.new
papers_array = Array.new
rowIdentifier = ""



dataTable.each do |row|
# 読者番号あれば
	if (row["読者番号"] != nil)
		customer_array.push(row[0..11])
# その次の行が読者番号なし（追加の新聞）である場合（この if が実行されない場合）に備え，読者番号ストック
		rowIdentifier = row[0]
	end
# 購読紙の情報で nil でない項目があるかどうか（本当なら row[12] が nil でなければいいのかも）
	if ( row[12..16].count {|x| x} > 0 )
		papers_array.push([rowIdentifier] + row[12..16])
	end
end #each


# dataTable.headers
output_customer = outputFile_name + "_customer.csv"
output_papers = outputFile_name + "_papers.csv"

CSV.open(output_customer,"wb", output_option) do |outputCSV|
	customer_array.each do |eachRow|
		outputCSV << eachRow
	end #each
end #

CSV.open(output_papers,"wb", output_option) do |outputCSV|
	papers_array.each do |eachRow|
		outputCSV << eachRow
	end #each
end #

