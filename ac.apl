#!/usr/bin/env dyalogscript

∇ initencode filename
  i←⊃⎕nget filename
  ⍝ frequency table
  t←({⍺(≢⍵)}⌸i),↑((¯1∘+∘⊃,⊃∘⊖)(⍸i∘=))¨∪i
  number_of_bits←8
  lower_bound←0
  upper_bound←¯1+2*number_of_bits-1
  second_quarter←2÷⍨upper_bound+1
  first_quarter←second_quarter÷2
  third_quarter←first_quarter×3
  cumulative_frequency←≢i
  e3_counter←0
  res←''
∇

∇ encode letter
  step←⌊cumulative_frequency÷⍨1+upper_bound-lower_bound
  upper_bound←lower_bound+¯1+step×t⌷⍨1 4×⊃⍸t=letter
  lower_bound←lower_bound+step×t⌷⍨1 3×⊃⍸t=letter

  :while (upper_bound<second_quarter)∨lower_bound≥second_quarter
    :if upper_bound<second_quarter
      lower_bound×←2
      upper_bound←1+upper_bound×2
      res,←'0',e3_counter⍴'1'
      e3_counter←0
    :endif
    :if lower_bound≥second_quarter
      lower_bound←2×lower_bound-second_quarter
      upper_bound←1+2×upper_bound-second_quarter
      res,←'1',e3_counter⍴'0'
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
    res,←'01',e3_counter⍴'1'
  :else
    res,←'10',e3_counter⍴'0'
  :endif
∇

∇ print_usage
    ⎕←'usage:'
    ⎕←'  ac.apl [option] [filename]'
    ⎕←'options:'
    ⎕←'  e : encode'
    ⎕←'  d : decode'
∇

∇ main args
  :if 3>≢args
    print_usage
  :elseif'e'=2⊃args
    initencode 3⊃args
    encode¨i
    endencode
    ⎕←number_of_bits,(,2↑⍉t),res
  :elseif'd'=2⊃args
    ⎕←3⊃args
  :else
    print_usage
  :endif
∇

main 2⎕nq#'getcommandlineargs'
