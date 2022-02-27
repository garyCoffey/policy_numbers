
class PolicyNumberProcessor

  def initialize(num)
    @num = num
  end

  def process
    policy_number = arrange_policy_number(@num).map { |num| symbols_to_num(num) }
    status = legible_valid_policy_number(policy_number)
    if (status == :ERR)
      status, policy_number = check_policy_number_alternatives(status, policy_number)
    end
    [policy_number, status]
  end

  private

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

  def symbols_to_num(symbols, mode = nil)
    zero = [
              " _ ", 
              "| |", 
              "|_|"
            ]
    one = [
            "   ", 
            " | ", 
            " | "
          ]
    two = [
            " _ ", 
            " _|", 
            "|_ "
          ]
    three = [
              " _ ", 
              " _|", 
              " _|"
            ]
    four = [
              "   ", 
              "|_|", 
              "  |"
            ]
    five = [
              " _ ", 
              "|_ ", 
              " _|"
            ]
    six = [
            " _ ", 
            "|_ ", 
            "|_|"
          ]
    seven = [
              " _ ", 
              "  |", 
              "  |"
            ]
    eight = [
              " _ ", 
              "|_|", 
              "|_|"
            ]
    nine = [
              " _ ", 
              "|_|", 
              " _|"
            ]
    numbers = {
      zero  => 0,
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

    if mode == :recheck_ill
      most_likely_keys = {}
      numbers.keys.each do |valid_symbols| 
        count = 0
        valid_symbols.each_with_index do |valid_sym, i|
          count += 1 if valid_sym == symbols[i]
          most_likely_keys[valid_symbols] = count
        end
      end
      highest_key_value = most_likely_keys.values.sort.last
      most_likely_key = most_likely_keys.key(highest_key_value)

      return highest_key_value != 0 ? numbers[most_likely_key] : '?'
    end

    numbers[symbols] ? numbers[symbols] : symbols_to_num(symbols, :recheck_ill)
  end

  def legible_valid_policy_number(policy_number)
    count = 0
    1.upto(9) do |i| 
      return :ILL if policy_number[-i] == '?'

      count += (policy_number[-i] * i)
    end

    count % 11 == 0 ? true : :ERR
  end

  def possible_alt_policy_nums(policy_num)
    alternative_policy_nums = []
    alts = {
              0 => [8],
              1 => [7],
              2 => [],
              3 => [],
              4 => [],
              5 => [6, 9],
              6 => [5],
              7 => [1],
              8 => [0, 9],
              9 => [5, 8]
            }
    policy_num.each_with_index do |num, i|
      tmp = policy_num.dup
      alts[num].each do |alt| 
        tmp[i] = alt
        alternative_policy_nums.push(tmp)
      end
    end
    alternative_policy_nums
  end

  def check_policy_number_alternatives(status, policy_number)
    result_policies = []
    result_status = nil
    possible_alt_policy_nums(policy_number).each do |alt|
      result_status = legible_valid_policy_number(alt)
      if result_status == true
        result_policies.push(alt)
      end
    end
    return [status, policy_number] if result_policies.empty?

    result_policies.length == 1 ? [true, result_policies[0]] : [:AMB, policy_number]
  end
end
