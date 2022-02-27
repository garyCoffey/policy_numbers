
def symbols_to_num(symbols)
  one = ["   ", " | ", " | "]
  two = [" _ ", " _|", "|_ "]
  three = [" _ ", " _|", " _|"]
  four = ["   ", "|_|", "  |"]
  five = [" _ ", "|_ ", " _|"]
  six = [" _ ", "|_ ", "|_|"]
  seven = [" _ ", "  |", "  |"]
  eight = [" _ ", "|_|", "|_|"]
  nine = [" _ ", "|_|", " _|"]
  numbers = {
    one   => 1,
    two   => 2,
    three => 3,
    four  => 4,
    five  => 5,
    six   => 6,
    seven => 7,
    eight => 8,
    nine  => 9
  }

  numbers[symbols] ? numbers[symbols] : '?'
end

def legible_valid_policy_number(policy_number)
  count = 0
  1.upto(9) do |i| 
    return :ILL if policy_number[-i] == '?'

    count += (policy_number[-i] * i)
  end

  count % 11 == 0 ? true : :ERR
end

def arrange_policy_number(policy_num)
  start = 0
  stop = 3
  num = []
  9.times do
    num.push([policy_num.slice(start...stop), 
              policy_num.slice((start + 27)...(stop + 27)),   
              policy_num.slice((start + 54)...(stop + 54))
            ])
    start += 3
    stop += 3
  end
  num
end

def execute
  file = File.open("test.txt")
  file_data = file.readlines.map(&:chomp)
  policy_numbers = []
  result = {}
  while file_data.length != 0 
    num = file_data.slice!(0...3).join
    policy_number = arrange_policy_number(num).map { |num| symbols_to_num(num) }
    result[policy_number] = { status: legible_valid_policy_number(policy_number) }
    policy_numbers.push(policy_number)
    file_data.slice!(0)
  end

  result.each do |k, v|
    File.write("result.txt", "#{k.join("")} #{v[:status] == true ? nil : v[:status]} \r\n", mode: "a")
  end
end

execute
