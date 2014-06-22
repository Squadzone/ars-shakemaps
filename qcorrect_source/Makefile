#Make file for compiling the program ICORRECT

OBJS= addzeros.o buttrhcf.o buttrlcf.o calc_stdist.o correct_eventlist.o\
	date2dayfrom1975.o date2doy.o deglitcher.o\
	detrender.o dirf.o doy2date.o ECTN_response.o FACC_smoother.o\
	fafp_calc.o filterer.o find_dat_resp.o findduration.o find_eqpar.o\
	find_event.o findstartsec.o fork.o fourierer.o freq_calc.o getinput.o\
	qcorrect.o i_strcmp.o julsec.o make_channeldirs.o make_evedir.o\
	make_FAP_resp.o make_GSE_resp.o make_PITSA_PAZ.o make_PSA.o\
	make_result_.o make_SAC_PAZ.o mark1.o mark2.o mark3.o mark5.o\
	merge_all.o merge_traces.o padder.o phase.o process_channel.o\
	PSA_smoother.o read_eventlist.o readpar.o readresp.o readtrace.o\
	repair_trace.o response.o respremover.o rscomp.o sdcomp.o serialn.o\
	skipline.o tracemaker.o windower.o win.o writer.o write_spec.o\
	write_for_matlab.o make_summary.o

#FC	= g77
FC	= gfortran
FFLAGS	= -O
#LINK.f	= g77
LINK.f	= gfortran
LIBS	=
LDFLAGS	=

.f.o:
	$(FC) $(FFLAGS) -c $<

qcorrect3: $(OBJS)
	$(LINK.f) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)

clean:
	@-rm -f $(OBJS)
