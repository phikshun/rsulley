class TestPrimitives < Test::Unit::TestCase
  include RSulley
  
  def test_groups_and_nums
    reset!
    
    request :unit_test_1 do
      size  :block, :length => 4, :name => :sizer
      group :group, "\x01", "\x05", "\x0a", "\xff"
      
      block :block do
        delim   ">",        :name => :delim
        string  "pedram",   :name => :string
        byte    0xde,       :name => :byte
        word    0xdead,     :name => :word
        dword   0xdeadbeef, :name => :dword
        qword   0xdeadbeefdeadbeef, :name => :qword
        random  0, :min => 5, :max => 10, :num => 100, :name => :random
      end
    end
    
    req1 = get :unit_test_1
    
    assert_equal req1.names[:random].num_mutations, 100
    assert_equal req1.names[:group].num_mutations, 4
    assert_equal req1.names[:block].num_mutations,
                 req1.names[:delim].num_mutations  +
                 req1.names[:string].num_mutations +
                 req1.names[:byte].num_mutations   +
                 req1.names[:word].num_mutations   +
                 req1.names[:dword].num_mutations  +
                 req1.names[:qword].num_mutations  +
                 req1.names[:random].num_mutations
    
    request :unit_test_2 do
      group :group, "\x01", "\x05", "\x0a", "\xff"
      block :block, :group => :group do
        delim   '>',        :name => :delim
        string  'pedram',   :name => :string
        byte    0xde,       :name => :byte
        word    0xdead,     :name => :word
        dword   0xdeadbeef, :name => :dword
        qword   0xdeadbeefdeadbeef, :name => :qword
        random  0, :min => 5, :max => 10, :num => 100, :name => :random
      end
    end
    
    req2 = get :unit_test_2
    assert_equal req2.names[:block].num_mutations, req1.names[:block].num_mutations * 4
  end
  
  def test_dependencies
    reset!
    
    request :dep_test_1 do
      group :group, "1", "2"
      block :one, :dep => :group, :dep_values => ["1"] do
        static "ONE" * 100
      end
      
      block :two, :dep => :group, :dep_values => ["2"] do
        static "TWO" * 100
      end
    end
    
    mutate
    assert_match /ONE/, render
    mutate
    assert_match /TWO/, render
  end
  
  def test_repeaters
    reset!
    
    request :rep_test_1 do
      block :block do
        delim   '>',        :name => :delim, :fuzzable => false
        string  "pedram",   :name => :string, :fuzzable => false
        byte    0xde,       :name => :byte, :fuzzable => false
        word    0xdead,     :name => :word, :fuzzable => false
        dword   0xdeadbeef, :name => :dword, :fuzzable => false
        qword   0xdeadbeefdeadbeef, :name => :qword, :fuzzable => false
        random  0, :min => 5, :max => 10, :num => 100, :name => :random, :fuzzable => false
      end
      repeat :block, :min => 5, :max => 15, :step => 5
    end
    
    data    = render
    length  = data.length
    
    mutate
    data    = render
    assert_equal data.length, length + length * 5
    
    mutate
    data    = render
    assert_equal data.length, length + length * 10
    
    mutate
    data    = render
    assert_equal data.length, length + length * 15
    
    mutate
    data    = render
    assert_equal data.length, length
  end
  
  def test_current_mutant
    reset!
    
    request :mutant_test_1 do
      dword   0xdeadbeef,        :name => :boss_hog
      string  'bloodhound gang', :name => :vagina
      
      block :block1 do
        string  'foo', :name => :foo
        string  'bar', :name => :bar
        dword   0x20
      end
      
      dword   0xdead
      dword   0x0fed
      
      string 'sucka free at 2 in the morning 7/18', :name => :uhntiss
    end
    
    req1 = get :mutant_test_1
    
    str_mutations = req1.names[:foo].num_mutations
    int_mutations = req1.names[:boss_hog].num_mutations
    
    0.upto(str_mutations + int_mutations - 10) do |i|
      req1.mutate
    end
    assert_equal :vagina, req1.mutant.name
    req1.reset
    
    0.upto(str_mutations + int_mutations) do |i|
      req1.mutate
    end
    assert_equal :foo, req1.mutant.name
    req1.reset
    
    0.upto(str_mutations * 2 + int_mutations + 1) do |i|
      req1.mutate
    end
    assert_equal :bar, req1.mutant.name
    req1.reset
    
    0.upto(str_mutations * 3 + int_mutations * 4 + 1) do |i|
      req1.mutate
    end
    assert_equal :uhntiss, req1.mutant.name
    req1.reset
  end
  
  def test_exhaustion
    reset!
    
    request :exhaustion_1 do
      string  'just wont eat', :name => :vip
      dword   0x4141,          :name => :eggos_rule
      dword   0x4242,          :name => :danny_glover_is_the_man
    end
    
    req1 = get :exhaustion_1
    
    str_mutations = req1.names[:vip].num_mutations
    
    0.upto(str_mutations / 2) do
      req1.mutate
    end
    req1.mutant.exhaust
    
    req1.mutate
    assert_equal :eggos_rule, req1.mutant.name
    req1.reset
    
    0.upto(str_mutations + 2) do
      req1.mutate
    end
    req1.mutant.exhaust
    
    req1.mutate
    assert_equal :danny_glover_is_the_man, req1.mutant.name
    req1.reset
    
    req1.mutant.exhaust
    req1.mutant.exhaust
    assert_equal :danny_glover_is_the_man, req1.mutant.name
  end
end







