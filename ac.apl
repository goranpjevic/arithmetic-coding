#!/usr/bin/env dyalogscript

∇ initencode filename
  i←11 ¯1⎕map filename
  number_of_bits←32
  i←2⊥¨i⊆⍨(≢i)⍴⊃,/number_of_bits⍴¨⍳⌈number_of_bits÷⍨≢i
  ⍝ frequency table
  t←tt,⍪((+\-⊢),(⍪+\))2⌷[2]tt←({⍺(≢⍵)}⌸i)
  lower_bound←0
  upper_bound←¯1+2*number_of_bits-1
  second_quarter←2÷⍨upper_bound+1
  first_quarter←second_quarter÷2
  third_quarter←first_quarter×3
  cumulative_frequency←≢i
  e3_counter←0
  res←⍬
∇

∇ encode letter
  step←⌊cumulative_frequency÷⍨1+upper_bound-lower_bound
  upper_bound←lower_bound+¯1+step×t⌷⍨4,⍨⊃⍸(1⌷[2]t)=letter
  lower_bound←lower_bound+step×t⌷⍨3,⍨⊃⍸(1⌷[2]t)=letter

  :while (upper_bound<second_quarter)∨lower_bound≥second_quarter
    :if upper_bound<second_quarter
      lower_bound×←2
      upper_bound←1+upper_bound×2
      res,←0,e3_counter⍴1
      e3_counter←0
    :endif
    :if lower_bound≥second_quarter
      lower_bound←2×lower_bound-second_quarter
      upper_bound←1+2×upper_bound-second_quarter
      res,←1,e3_counter⍴0
      e3_counter←0
    :endif
  :endwhile

  :while (lower_bound≥first_quarter)∧upper_bound<third_quarter
    lower_bound←2×lower_bound-first_quarter
    upper_bound←1+2×upper_bound-first_quarter
    e3_counter+←1
  :endwhile
∇

∇ endencode
  :if lower_bound<first_quarter
    res,←0 1,e3_counter⍴1
  :else
    res,←1 0,e3_counter⍴0
  :endif
∇

∇ initdecode filename
  i←11 ¯1⎕map filename
  number_of_bits←2⊥32↑i
  number_of_unique_codes←2⊥number_of_bits↑32↓i
  t_bits←(number_of_unique_codes×number_of_bits×2)↑(32+number_of_bits)↓i
  t_numbers←2⊥¨t_bits⊆⍨(≢t_bits)⍴⊃,/number_of_bits⍴¨⍳⌈number_of_bits÷⍨≢t_bits
  t←tt,⍪((+\-⊢),(⍪+\))2⌷[2]tt←number_of_unique_codes 2⍴t_numbers
  i↓⍨←32+number_of_bits+number_of_unique_codes×number_of_bits×2
  input_array←2⊥(number_of_bits-1)↑i
  i↓⍨←number_of_bits-1
  i,←number_of_bits⍴0

  cumulative_frequency←+/2⌷[2]t
  lower_bound←0
  upper_bound←¯1+2*number_of_bits-1
  second_quarter←2÷⍨upper_bound+1
  first_quarter←second_quarter÷2
  third_quarter←first_quarter×3
  res←⍬
∇

∇ decode code
  step←⌊cumulative_frequency÷⍨1+upper_bound-lower_bound
  v←⌊(input_array-lower_bound)÷step
  letter←(⊃⌽⍸v≥3⌷[2]t)1⌷t
  res,←letter
  upper_bound←lower_bound+¯1+step×t⌷⍨4,⍨⊃⍸(1⌷[2]t)=letter
  lower_bound←lower_bound+step×t⌷⍨3,⍨⊃⍸(1⌷[2]t)=letter

  :While (upper_bound<second_quarter)∨lower_bound≥second_quarter
    :If upper_bound<second_quarter
      lower_bound×←2
      upper_bound←1+upper_bound×2
      input_array←(2×input_array)+⊃i
      i↓⍨←1
    :EndIf
    :If lower_bound≥second_quarter
      lower_bound←2×lower_bound-second_quarter
      upper_bound←1+2×upper_bound-second_quarter
      input_array←(2×input_array-second_quarter)+⊃i
      i↓⍨←1
    :EndIf
  :EndWhile

  :While (lower_bound≥first_quarter)∧upper_bound<third_quarter
    lower_bound←2×lower_bound-first_quarter
    upper_bound←1+2×upper_bound-first_quarter
    input_array←(2×input_array-first_quarter)+⊃i
    i↓⍨←1
  :EndWhile
∇

∇ print_usage
    ⎕←'usage:'
    ⎕←'  ac.apl [option] [input_filename] [output_filename]'
    ⎕←'options:'
    ⎕←'  e : encode a file'
    ⎕←'  d : decode a file'
∇

∇ main args
  :if 4>≢args
    print_usage
  :elseif'e'=2⊃args
    initencode 3⊃args
    encode¨i
    endencode
    o←(4⊃args)(⎕ncreate⍠'IfExists' 'Replace')0
    output_bits←res,⍨((32⍴2)⊤number_of_bits),⊃,/(number_of_bits⍴2)∘⊤¨(≢t),,2↑[2]t
    output_bits⎕nappend o 11
  :elseif'd'=2⊃args
    initdecode 3⊃args
    decode¨⍳cumulative_frequency
    o←(4⊃args)(⎕ncreate⍠'IfExists' 'Replace')0
    output_bits←⊃,/(number_of_bits⍴2)∘⊤¨res
    output_bits⎕nappend o 11
  :else
    print_usage
  :endif
∇

main 2⎕nq#'getcommandlineargs'
