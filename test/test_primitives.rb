class TestPrimitives < Test::Unit::TestCase
  include RSulley
  
  def test_signed
    reset!
    
    request :unit_test_1 do
      byte 0,         :format => :ascii, :signed => true, :name => 'byte_1'
      byte 0xff/2,    :format => :ascii, :signed => true, :name => 'byte_2'
      byte 0xff/2+1,  :format => :ascii, :signed => true, :name => 'byte_3'
      byte 0xff,      :format => :ascii, :signed => true, :name => 'byte_4'
      
      word 0,           :format => :ascii, :signed => true, :name => 'word_1'
      word 0xffff/2,    :format => :ascii, :signed => true, :name => 'word_2'
      word 0xffff/2+1,  :format => :ascii, :signed => true, :name => 'word_3'
      word 0xffff,      :format => :ascii, :signed => true, :name => 'word_4'
      
      dword 0,               :format => :ascii, :signed => true, :name => 'dword_1'
      dword 0xffffffff/2,    :format => :ascii, :signed => true, :name => 'dword_2'
      dword 0xffffffff/2+1,  :format => :ascii, :signed => true, :name => 'dword_3'
      dword 0xffffffff,      :format => :ascii, :signed => true, :name => 'dword_4'
      
      qword 0,                       :format => :ascii, :signed => true, :name => 'qword_1'
      qword 0xffffffffffffffff/2,    :format => :ascii, :signed => true, :name => 'qword_2'
      qword 0xffffffffffffffff/2+1,  :format => :ascii, :signed => true, :name => 'qword_3'
      qword 0xffffffffffffffff,      :format => :ascii, :signed => true, :name => 'qword_4'
    end
    
    req = get :unit_test_1
    
    assert_equal req.names['byte_1'].render, "0"
    assert_equal req.names['byte_2'].render, "127"
    assert_equal req.names['byte_3'].render, "-128"
    assert_equal req.names['byte_4'].render, "-1"
    
    assert_equal req.names['word_1'].render, "0"
    assert_equal req.names['word_2'].render, "32767"
    assert_equal req.names['word_3'].render, "-32768"
    assert_equal req.names['word_4'].render, "-1"
    
    assert_equal req.names['dword_1'].render, "0"
    assert_equal req.names['dword_2'].render, "2147483647"
    assert_equal req.names['dword_3'].render, "-2147483648"
    assert_equal req.names['dword_4'].render, "-1"
    
    assert_equal req.names['qword_1'].render, "0"
    assert_equal req.names['qword_2'].render, "9223372036854775807"
    assert_equal req.names['qword_3'].render, "-9223372036854775808"
    assert_equal req.names['qword_4'].render, "-1"
  end
  
  def test_strings
    reset!
    
    request :string_unit_test_1 do
      string "foo", :name => 'sized_string', :size => 200
    end
    
    req = get :string_unit_test_1
    
    assert_equal req.names['sized_string'].render.length, 3
    
    50.times do
      mutate
      assert_equal req.names['sized_string'].render.length, 200
    end
  end
end
  
  
  
  
  
  
  