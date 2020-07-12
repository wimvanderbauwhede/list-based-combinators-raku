use v6;
use ListBasedCombinators;

# sub seq {
# 	my \ps = @_;
# 	sequence( Array[LComb](ps) );
	
# }

# sub choice_ {
# my \ps = @_;
# choice( Array[LComb](ps));

# } 
my $str = 'hello, world';
say apply word,$str;
my $str2 = ';hello, world';
say apply word,$str2 ;

#my LComb @ws = (word,word);
#sequence(@ws);
say "test seq";
my $str3 = 'hello, world; answer = 42';
my $ms = apply
	#sequence( Array[LComb](
		sequence(
		word, comma, word, 
		semi, 
		word, symbol('='),natural  ), $str3
;
multi sub defMatch(Match[Str] $m) { True }
multi sub defMatch(UndefinedMatch $u) { False }


say $ms.matches.grep: Match[Str];
say map {.match} ,grep Match[Str], |$ms.matches;


my $str4 = 'answer = hello( world)';
my $ms4 = apply(
	sequence( #Array[LComb](
		word, symbol('='), word, parens(word)
		#) 
    ), $str4
);
say $ms4;
say map {.match} ,grep Match[Str], |$ms4.matches;
my \type_str = "integer(kind=8), ";
my \test_parser = 
  sequence(
    whiteSpace,
    # Tag[ "Type", word].new,
    tag("Type",word),
    word,
    word,
    symbol( "="),
    natural
  );

my \type_parser =     
    sequence(
        Tag[ "Type", word].new,
        maybe( parens( 
            choice( 
                Tag[ "Kind" ,natural].new,
                sequence(
                    symbol( "kind"),
                    symbol( "="),
                    Tag[ "Kind", natural].new
	              )
              )
            )
          )
      ); 

my $resh1 =  apply( test_parser, "   hello world   spaces =  7188 .");
say $resh1.raku;
# my $resh2 = apply( type_parser, type_str);   
my (\tpst,\tpstr,\tpms) = unmtup apply( type_parser, type_str);# $resh2;   
say 'Matches: ',tpms;
# apply (sepBy (symbol "=>") word) "Int => Bool => String"    
# apply (sequence(oneOf "aeiou", word]) "aTest"    
#    let
#        MTup (st,str,ms) = apply (sequence(word, symbol "=", word,parens word]) "answer = hello(world)"  
# (st,str,ms)        
say getParseTree( tpms);


my \term_str = "a*x^2+ 4*b*x +c";

my \term_parser =  Tag[ "Add", sequence(
            Tag[ "Mult", sequence(
                Tag[ "Par", word].new,
                symbol( "*"),
                Tag[ "Pow" , sequence(
                    Tag[  "Var", word].new,
                    symbol( "^"),
                    Tag[ "Const", natural].new
                )].new
            )].new,
            symbol( "+"),
            Tag[ "Mult", sequence(
                Tag[ "Const", natural].new,
                symbol( "*"),
                Tag[ "Par", word].new,
                symbol( "*"),
                Tag[ "Var", word].new
            )].new,     
            symbol( "+"),       
            Tag[ "Par", word].new
      )].new;

my (\tpst2,\tpstr2,\tpms2) = unmtup apply( term_parser, term_str);       
say "\nParse Tree for Term expression:\n";
say taggedEntryToTerm(getParseTree( tpms2).head);


#  Now let's try something like a*x^2+b*x+c
role Term {}
role Var [Str \v] does Term {
    has Str $.var = v;
}
role Par [Str \p] does Term {
    has Str $.par = p;
}
role Const [Int \c] does Term {
    has Int $.const = c;
}
role Pow [Term \t, Int \n] does Term {
    has Term $.term = t;
    has Int $.exp = n;
}
role Add [Array[Term] \ts] does Term {
    has Array[Term] $.terms = ts;
}
role Mult [Array[Term] \ts] does Term {
    has Array[Term] $.terms = ts;
}

multi sub taggedEntryToTerm (["Var", TaggedEntry \val_strs]) { Var[ val_strs.val.head].new }
multi sub taggedEntryToTerm (["Par", TaggedEntry \par_strs]) { Par[par_strs.val.head].new }
multi sub taggedEntryToTerm (["Const", TaggedEntry \const_strs]) {Const[ Int(const_strs.val.head)].new } 
multi sub taggedEntryToTerm (["Pow", TaggedEntry \pow_strs]) {
  my (\vt, \et)   = pow_strs.valmap;
  Pow[ taggedEntryToTerm(vt), Int(et.[1].val)].new
}        
multi sub taggedEntryToTerm (["Add", TaggedEntry \hmap]) { 
  my \res = map {taggedEntryToTerm($_)}, |hmap.valmap;
  Add[ Array[Term].new(res)].new
}
multi sub taggedEntryToTerm (["Mult", TaggedEntry \hmap]) {  
  my \res = map {taggedEntryToTerm($_)}, |hmap.valmap;
  Mult[ Array[Term].new(res)].new
}

my \mkVar = sub (Array[Matches] \m --> Term) { Var[ m.head.match ].new }
my \mkPar = sub ( \m) {  Par[ m.head.match ].new }
my \mkConst = sub ( \m) { Const[ Int(m.head.match) ].new }
my \mkPow = sub ( \ms) {
  my (\vt,\et) = getTaggedMatches(Term, ms);
  Pow[ vt, et.const ].new
}
my \mkAdd = sub (\ms) {
  Add[ getTaggedMatches(Term, ms) ].new;
}
my \mkMult = sub (\ms) {
  Mult[ getTaggedMatches(Term, ms) ].new
}


my \term_parser_new =  Tag[ mkAdd, sequence(
            Tag[ mkMult, sequence(
                Tag[ mkPar, word].new,
                symbol( "*"),
                Tag[ mkPow , sequence(
                    Tag[  mkVar, word].new,
                    symbol( "^"),
                    Tag[ mkConst, natural].new
                )].new
            )].new,
            symbol( "+"),
            Tag[ mkMult, sequence(
                Tag[ mkConst, natural].new,
                symbol( "*"),
                Tag[ mkPar, word].new,
                symbol( "*"),
                Tag[ mkVar, word].new
            )].new,     
            symbol( "+"),       
            Tag[ mkPar, word].new
      )].new;

my (\tpst2n,\tpstr2n,\tpms2n) = unmtup apply( term_parser_new, term_str);     

say "\nParse Tree for Term expression:\n";
# say tpms2n.raku
say getTaggedMatches( Term, tpms2n).head;
