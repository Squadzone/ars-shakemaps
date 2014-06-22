      subroutine process_channel(dat_file,resp_file)
      use traceinfo
      use timeseries
      use par
      implicit none
      integer                     :: inst_corr_flag
      real, dimension (1000)      :: freqpsa ,psa
      character (len=50)          :: dat_file, resp_file
C     Read trace, calculate day, month, and epicentral distance of site
      call repair_trace(dat_file)
      call readtrace(dat_file)
      call doy2date(year, month, day, doy)
      call calc_stdist()
C     Read instrument response information and write response file data
C     in multiple formats.
      call ECTN_response(staname, event, inst_corr_flag)
      call readresp(resp_file, inst_corr_flag)
c      call make_GSE_resp()
c      call make_PITSA_PAZ()
c      call make_SAC_PAZ()
c      call make_FAP_resp()
CC     Do the processing of time series and write the results
      deglitched=trace
ccc      write(*,*)'deglitcher:'
      call deglitcher(deglitched, nsamp, iglit) ! This routine was originally made by G.Atkinson
ccc      write(*,*)'detrender:'
      call detrender()
ccc      write(*,*)'windower:'
      call windower ()
ccc      write(*,*)'padder:'
      call padder()
ccc      write(*,*)'freq_calc:'
      call freq_calc()
ccc      write(*,*)'fourierer:'
      call fourierer()
ccc      write(*,*)'filterer:'
      call filterer()
ccc      write(*,*)'respremover:'
      call respremover()
ccc      write(*,*)'tracemaker:'
      call tracemaker()
c      write(*,*)'make_result_:'
c      call make_result_()
ccc      write(*,*)'writer:'
      call writer()
CC     Calculate and write response spectrum of the accelerogram
ccc      write(*,*)'make_PSA:'
      call make_PSA(freqpsa ,psa)
      call make_summary(freqpsa ,psa)
C     Calculate and write fourier spectrum of the accelerogram
C      write(*,*)'fafp_calc:'
C      call fafp_calc()
C      write(*,*)'FACC_smoother:'
C      call FACC_smoother()
C      write(*,*)'write_spec:'
C      call write_spec()
      return
      end
