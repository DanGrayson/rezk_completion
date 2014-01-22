# -*- makefile-gmake -*-
include Make.makefile
OTHERFLAGS += -no-sharing

TIME=gnu
ifeq ($(TIME),gnu)
TIMECMD = \time -f "%U sec, %M bytes"
else
ifeq ($(TIME),bsd)
TIMECMD = \time -p
else
ifeq ($(TIME),bash)
TIMECMD = time -p
else
TIMECMD = time
endif
endif
endif
COQC := $(TIMECMD) $(COQC)

COQDEFS := --language=none -r '/^[[:space:]]*\(Axiom\|Theorem\|Class\|Instance\|Let\|Ltac\|Definition\|Lemma\|Record\|Remark\|Structure\|Fixpoint\|Fact\|Corollary\|Let\|Inductive\|Coinductive\|Notation\|Proposition\|Module[[:space:]]+Import\|Module\)[[:space:]]+\([[:alnum:]'\''_]+\)/\2/'
TAGS : $(VFILES); etags $(COQDEFS) $^
clean:clean2
clean2:; rm -f TAGS N*.cmi N*.cmx N*.cmxs N*.native N*.o *.v.d
