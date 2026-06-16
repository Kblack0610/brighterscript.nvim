" Vim syntax file
" Language:    BrightScript / BrighterScript (Roku & BrightSign)
" Maintainer:  brighterscript.nvim
" Filenames:   *.brs *.bs
"
" BrightScript is case-insensitive; keywords are matched accordingly.

if exists("b:current_syntax")
  finish
endif

syn case ignore

" --- Comments ---------------------------------------------------------------
" Apostrophe comments and the REM keyword both run to end of line.
syn match   bsComment "'.*$" contains=bsTodo
syn match   bsComment "\<rem\>.*$" contains=bsTodo
syn keyword bsTodo    TODO FIXME XXX HACK NOTE contained

" --- Strings ----------------------------------------------------------------
" Double-quoted; embedded quotes are escaped by doubling ("").
syn region  bsString  start=+"+ skip=+""+ end=+"+ oneline

" --- Numbers ----------------------------------------------------------------
syn match   bsNumber  "\<\d\+\>"
syn match   bsNumber  "\<\d\+\.\d*\>"
syn match   bsNumber  "\<\.\d\+\>"
syn match   bsNumber  "\<\d\+[eE][-+]\=\d\+\>"
syn match   bsNumber  "&[hH]\x\+\>"
syn match   bsNumber  "\<\d\+[&!#]"

" --- Declarations -----------------------------------------------------------
syn keyword bsKeyword sub function as return
syn keyword bsKeyword dim const library
" BrighterScript (.bs) extensions
syn keyword bsKeyword class namespace import interface enum try catch throw

" --- Control flow -----------------------------------------------------------
syn keyword bsConditional if then else elseif endif
syn keyword bsRepeat      for to step each in while until
syn keyword bsStatement   end exit next stop goto print
syn match   bsStatement   "\<end\s\+\(sub\|function\|if\|for\|while\|class\|namespace\|interface\|enum\|try\)\>"
syn match   bsRepeat      "\<exit\s\+\(for\|while\)\>"
syn match   bsRepeat      "\<for\s\+each\>"

" --- Operators (word form) --------------------------------------------------
syn keyword bsOperator and or not mod
syn match   bsOperator "[-+*/\\<>=]"
syn match   bsOperator "<>"
syn match   bsOperator "<="
syn match   bsOperator ">="

" --- Constants / literals ---------------------------------------------------
syn keyword bsBoolean  true false
syn keyword bsConstant invalid LINE_NUM
syn keyword bsType     integer longinteger float double string boolean object dynamic void

" --- Builtins ---------------------------------------------------------------
syn keyword bsFunction CreateObject GetGlobalAA Type Box Run Eval RebootSystem
syn keyword bsFunction Sleep Wait UpTime Stri Str Val Chr Asc Left Right Mid Len
syn keyword bsFunction Instr Tab Pos Abs Cdbl Cint Csng Fix Int Sgn Atn Cos Sin Tan
syn keyword bsFunction Exp Log Sqr Rnd FormatJson ParseJson ReadAsciiFile WriteAsciiFile

" m / global references
syn keyword bsKeyword  m global super

" --- ro* objects (highlight as a type-ish identifier) -----------------------
syn match   bsRoObject "\<ro[A-Z][A-Za-z0-9_]*\>"
syn match   bsIfObject "\<if[A-Z][A-Za-z0-9_]*\>"

" --- Function call name (subtle) --------------------------------------------
syn match   bsFunctionCall "\<[A-Za-z_][A-Za-z0-9_]*\ze\s*("

" --- Highlight links --------------------------------------------------------
hi def link bsComment      Comment
hi def link bsTodo         Todo
hi def link bsString       String
hi def link bsNumber       Number
hi def link bsKeyword      Keyword
hi def link bsConditional  Conditional
hi def link bsRepeat       Repeat
hi def link bsStatement    Statement
hi def link bsOperator     Operator
hi def link bsBoolean      Boolean
hi def link bsConstant     Constant
hi def link bsType         Type
hi def link bsFunction     Function
hi def link bsFunctionCall Function
hi def link bsRoObject     Structure
hi def link bsIfObject     Structure

let b:current_syntax = "brightscript"
