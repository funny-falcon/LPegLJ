package.path = "./src/?.lua;"..package.path
local lpeg = require 'lpeglj'
local re = require 're'
local ipairs = ipairs
local tinsert, tconcat = table.insert, table.concat
local sformat = string.format

local gram
gram = {
    ident = function()end,
    num = function()end,
    const = function()end,
    sized = function()end,
    sized_string = function()end,
    sized_skip = function()end,
    string = function()end,
    skip = function()end,
    layout = function()end,
    struct = function()end,
    array = function()end,
    tuple = function()end,
    ar_cnt_sz = function()end,
    ar_sz_cnt = function()end,
    ar_cnt = function()end,
    ar_var = function()end,
    sboxr = function()end,
    sboxq = function()end,
    fposed = function()end,
    fposed_rep = function()end,
    fnamed = function()end,
    fsname = function()end,
    fcname = function()end,
    fnname = function()end,
    fields = function()end,
}

local typegram = re.compile([[
    tdef <- s* type s* !.
    type <- sized / raw
    raw <- sizeable / layout
    sizeable <- num / string / skip / struct / tuple / array / sboxr / sboxq / sized --/ ident

    sized <- (metrics ls* "/" ls* sizeable) -> sized /
             ("[" ls* metrics ls* "]" ls* "char") -> sized_string /
             ("[" ls* metrics ls* "]" ls* "skip") -> sized_skip
    metric <- num / const
    metrics <- metric / {"*"}
    metricu <- metric / ""->"*"
    const <- (%d+!%d) -> const

    --ident <- i -> ident
    num <- ((({"i"}"nt"?/{"u"}"int"?) {"8"/"16"/"32"/"64"} ("b""e"?->"be"/("l""e"?/"")->"")) -> "%1%2%3" / "L"->"i32" / "ber" / "b""yte"?->"u8") -> num !%w
    string <- ("str""ing"?/"["ls*"]"ls*"char") -> string !%w
    skip <- "skip" -> skip !%w

    layout <- "(" s* fields->layout s* ")"
    struct <- "{" s* fields->struct s* "}"

    array <- ("["ls* asizecount ls* "]"ls* sizeable) -> array
    tuple <- ("["ls* asizecount ls* "\"ls* num ls* "]"ls* type) -> tuple
    asizecount <- (num ls*"/"ls* metric) -> ar_sz_cnt / 
                  (num ls+ num ls*"/") -> ar_cnt_sz /
                  metric->ar_cnt / ""->ar_var
    sboxr <- "sboxr("s* fields->sboxr s*")"
    sboxq <- "sboxq("s* fields->sboxq s*")"

    fields <- {| field (sep field)* |}->fields sep?
    field <- fnamed / fposed
    fnamed <- ({| fname (ls*","s* fname)* |} s* {":"/"!"/"<-"} ls* type) -> fnamed
    fname <- "sz("ls* i->fsname ls*")" / "cnt("ls* i->fcname ls*")" / i->fnname
    fposed <- (metricu "*" ls* {"!"?} ls* type)->fposed_rep / ({"!"?} ls* type)->fposed

    i <- !%d%w+!%w

    ftype <- {:type: type :}

    nl <- ("--" (!%nl .)*)? %nl
    sep <- ls* ((";" / nl) ls*)+
    s <- %s / nl
    ls <- !%nl %s
]], gram)
