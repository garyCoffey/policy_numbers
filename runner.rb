require './policy_number_processor'

def execute
  file = File.open("test.txt")
  file_data = file.readlines.map(&:chomp)
  result = {}
  while file_data.length != 0 
    num = file_data.slice!(0...3).join
    policy_number, status = PolicyNumberProcessor.new(num).process
    result[policy_number] = { status: status }
    file_data.slice!(0)
  end

  result.each do |k, v|
    File.write("result.txt", "#{k.join("")} #{v[:status] == true ? nil : v[:status]} \r\n", mode: "a")
  end
end

execute
