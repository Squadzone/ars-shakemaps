      subroutine make_PSA(freqpsa ,psa)
      use traceinfo
      use par
      use timeseries
      implicit none
      integer                     :: i
      real, dimension (1000)      :: freqpsa ,psa ,smooth
c      open(unit=15,file='PSA.out',status='unknown')
      open(unit=15,file=trim(staname)//'.'//trim(comp)//'.psa',
     1     status='unknown')
      call rscomp(acc,freqpsa,psa)
      call PSA_smoother(freqpsa,psa,smooth)
      write(15,*)'Station:   ',staname
      write(15,*)'Component: ',comp
      write(15,*)'Calculated PSA for the frequency range: '
      write(15,*)freq1,' Hz and ',freq2,' Hz'
      write(15,*)nfreq,'frequencies distributed logarithmically'
      write(15,*)'Oscillator damping is',damp,'% of critical'
c      write(15,'(a64)')'  Freq.(Hz)       Period(s)      PSA(cm/s^2)  Sm
c     1ooth PSA(cm/s^2)'
      write(15,'(a28)')'  Freq.(Hz)      PSA(cm/s^2)'
      do i=nfreq,1,-1
c           write(15,*)freqpsa(i),1/freqpsa(i),psa(i),smooth(i)
           write(15,*)freqpsa(i),psa(i)
      enddo 
      close(unit=15)
      return
      end
