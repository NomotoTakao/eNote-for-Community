require 'fileutils'

# table_list.txtを開く
table_list = File.open("./db/trigger/table_list.txt", "r")
lines = table_list.readlines
table_list.close

# example.txtを開く
example = File.open("./db/trigger/example.txt", "r");
example_lines = example.readlines
example.close

#TODO table_list.txtの各行に対して、ループ
lines.each do |line|
  
  path = "./db/trigger/" + line.chomp + ".trigger"
  tmp = File.open(path, "a")
  
  table_name = line.chomp
p "table_name:" + table_name
  function_name = line.chomp + "_function"
p "function_name:" + function_name
  trigger_name = line.chomp + "_trigger"
p "trigger_name:" + trigger_name
  example_lines.each do |example_line|
    if example_line.include?(":table_name")
      example_line = example_line.gsub(":table_name", table_name)
    end
    if example_line.include?(":function_name")
      example_line = example_line.gsub(":function_name", function_name)
    end
    if example_line.include?(":trigger_name")
      example_line = example_line.gsub(":trigger_name", trigger_name)
    end
p "example_line:" + example_line
    tmp.write example_line
  end
  tmp.close
p "close"
end



