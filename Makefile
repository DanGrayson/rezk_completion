# -*- makefile-gmake -*-
# To compile with coq 8.3, run "make VERSION=8.3".  That will prevent using unknown command line options.
VERSION = 8.4
ifeq ("$(VERSION)","8.4")
OTHERFLAGS += -indices-matter
# compiling uu0 takes 32 seconds with sharing and 20 seconds with no-sharing, using a patched coq 8.4
# OTHERFLAGS += -no-sharing
OTHERFLAGS += -no-native-compiler
# OTHERFLAGS += -verbose
else
endif

COQTIME = yes
ifeq ("$(COQTIME)","yes")
OTHERFLAGS += -time
endif

include Make.makefile

TIME=gnu
ifeq ($(TIME),gnu)
TIMECMD = \time -f "%U sec, %M bytes: $*"
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

ifeq ("$(COQTIME)","yes")
COQC = : compiling $*.v ; >$*.timing $(TIMECMD) $(COQBIN)coqc
else
COQC = : compiling $*.v ; $(TIMECMD) $(COQBIN)coqc
endif

topten: $(VOFILES)
	@find . -name \*.timing | while read x ; do if [ -f "$$x" ] ; then grep '^Chars' "$$x" | sed -e "s=^=$$x =" -e "s/timing/v/" -e "s/ Chars /:/" -e "s/ - \([0-9]*\)/-\1:/"; fi; done | sort -grk 3 | head -10
COQDEFS := --language=none -r '/^[[:space:]]*\(Axiom\|Theorem\|Class\|Instance\|Let\|Ltac\|Definition\|Lemma\|Record\|Remark\|Structure\|Fixpoint\|Fact\|Corollary\|Let\|Inductive\|Coinductive\|Notation\|Proposition\|Module[[:space:]]+Import\|Module\)[[:space:]]+\([[:alnum:]'\''_]+\)/\2/'
TAGS : $(VFILES); etags $(COQDEFS) $^
clean:clean2
clean2:
	rm -f TAGS
	find . \( -name \*.o -o -name \*.cmi -o  -name \*.cmx -o -name \*.cmxs -o -name \*.native -o -name .\*.aux -o -name \*.timing \) -delete
