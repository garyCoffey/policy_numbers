require './policy_number_processor'

def build_test_cases(file)
  file = File.open("./test_files/#{file}.txt")
  file_data = file.readlines.map(&:chomp)
  numbers = []
  while file_data.length != 0 
    num = file_data.slice!(0...3).join
    numbers.push(num)
    file_data.slice!(0)
  end
  numbers
end

shared_examples_for 'policy number processor' do |numbers, test_output_map|
  numbers.each do |num|
    policy = PolicyNumberProcessor.new(num)
    describe '#process' do 
      it 'returns expected output' do 
        expect(policy.send(:process)).to eq(test_output_map[num])
      end
    end
  end
end

RSpec.describe PolicyNumberProcessor do

  describe 'unit' do 
    describe '#arrange_policy_number' do
      let(:test_cases) {  build_test_cases('valid_policy_number') }
      let(:policy_num)     { PolicyNumberProcessor.new(test_cases[0]).send(:arrange_policy_number, test_cases[0]) }
      let(:expected_output) do 
        [
          [
            "   ", 
            " | ", 
            " | "
          ], 
          [
            " _ ", 
            " _|", 
            "|_ "
          ], 
          [
            " _ ", 
            " _|", 
            " _|"
          ], 
          [
            "   ", 
            "|_|", 
            "  |"
          ], 
          [
            " _ ", 
            "|_ ", 
            " _|"
          ], 
          [
            " _ ", 
            "|_ ", 
            "|_|"
          ], 
          [
            " _ ",
             "  |", 
             "  |"
          ], 
          [
            " _ ", 
            "|_|",
            "|_|"
          ], 
          [
            " _ ", 
            "|_|", 
            " _|"
          ]
        ]
      end

      it 'returns correct policy number' do 
        expect(policy_num).to eq(expected_output)
      end
    end
    
    describe '#symbols_to_num' do
      let(:policy_num) { PolicyNumberProcessor.new("").send(:symbols_to_num, symbol) }
      context 'symbol is included in data map' do
        let(:symbol) do
          [
            "   ", 
            " | ", 
            " | "
          ]
        end
        it 'returns expected number' do 
          expect(policy_num).to eq(1)
        end
      end
      
      context 'symbol is not included in data map' do
        let(:symbol) do
          [
            "   ", 
            "   ", 
            " | "
          ]
        end
        it 'returns most likely number' do 
          expect(policy_num).to eq(1)
        end
      end
    end

    describe '#legible_valid_policy_number' do 
      let(:checksum) { PolicyNumberProcessor.new("").send(:legible_valid_policy_number, policy_number) }
      context 'policy number is valid' do
        let(:policy_number) { [1, 2, 3, 4, 5, 6, 7, 8, 9] }
        it 'returns expected number' do 
          expect(checksum).to eq(true)
        end
      end

      context 'policy number has error' do
        let(:policy_number) { [1, 1, 1, 1, 1, 1, 1, 1, 1] }
        it 'returns expected number' do 
          expect(checksum).to eq(:ERR)
        end
      end

      context 'policy number has illegible character' do
        let(:policy_number) { [1, 1, 1, 1, 1, '?', 1, 1, 1] }
        it 'returns expected number' do 
          expect(checksum).to eq(:ILL)
        end
      end
    end

    describe '#possible_alt_policy_nums' do 
      let(:alts) { PolicyNumberProcessor.new("").send(:possible_alt_policy_nums, policy_number) }
      context 'policy number has many alts' do
        let(:policy_number) { [0, 1, 5, 6, 7, 8, 9, 5, 5] }
        let(:expected_output) do 
          [
            [0, 1, 5, 5, 7, 8, 9, 5, 5], 
            [0, 1, 5, 6, 7, 9, 9, 5, 5],
            [0, 1, 5, 6, 1, 8, 9, 5, 5], 
            [0, 1, 5, 6, 7, 8, 8, 5, 5], 
            [0, 1, 5, 6, 7, 8, 9, 5, 9],
            [0, 1, 5, 6, 7, 8, 9, 9, 5],
            [0, 1, 9, 6, 7, 8, 9, 5, 5], 
            [0, 7, 5, 6, 7, 8, 9, 5, 5], 
            [8, 1, 5, 6, 7, 8, 9, 5, 5]
          ]
        end
        it 'returns expected number' do 
          alts.each do |alt| 
             expect(expected_output.include?(alt)).to eq(true) 
          end
        end
      end

      context 'policy number has no alts' do
        let(:policy_number) { [2, 2, 2, 2, 2, 2, 2, 2, 2] }

        it 'returns expected number' do 
          expect(alts).to eq([])
        end
      end
    end

    describe '#check_policy_number_alternatives' do 
      before do 
        allow_any_instance_of(PolicyNumberProcessor).to receive(:possible_alt_policy_nums).and_return(mock_alt_policy_numbers)
        allow_any_instance_of(PolicyNumberProcessor).to receive(:legible_valid_policy_number).and_return(true)
      end
      let(:policy_number_err) { [1, 1, 1, 1, 1, 1, 1, 1, 1] }
      let(:policy_num_alt_output) { PolicyNumberProcessor.new("").send(:check_policy_number_alternatives, :ERR, policy_number_err) }

      context 'policy number has 1 valid alt' do
      
        let(:mock_alt_policy_numbers) { [[1, 2, 3, 4, 5, 6, 7, 8, 9]] }

        it 'returns alternative policy number' do  
          expect(policy_num_alt_output).to eq([true, mock_alt_policy_numbers[0]])
        end
      end

      context 'policy number has multiple valid alt' do
      
        let(:mock_alt_policy_numbers) { [[1, 2, 3, 4, 5, 6, 7, 8, 9], [1 ,2 ,3 , 4, 5, 6, 7, 8, 7]] }

        it 'returns alternative policy number' do  
          expect(policy_num_alt_output).to eq([:AMB, policy_number_err])
        end
      end

      context 'policy number has no valid alt' do
        before do 
          allow_any_instance_of(PolicyNumberProcessor).to receive(:possible_alt_policy_nums).and_return(mock_alt_policy_numbers)
          allow_any_instance_of(PolicyNumberProcessor).to receive(:legible_valid_policy_number).and_return(:ERR)
        end

        let(:mock_alt_policy_numbers) { [[1, 2, 3, 4, 5, 6, 7, 8, 9]] }

        it 'returns alternative policy number' do  
          expect(policy_num_alt_output).to eq([:ERR, policy_number_err])
        end
      end
    end
  end

  describe 'functional' do 
    context '1 valid policy number input' do
      test_cases = build_test_cases('valid_policy_number')
      expected_outputs =  {
                            test_cases[0] => [[1, 2, 3, 4, 5, 6, 7, 8, 9], true]
                          }
      it_should_behave_like 'policy number processor', test_cases, expected_outputs
    end
  end
end
