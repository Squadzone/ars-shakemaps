      subroutine write_spec()
      use traceinfo
      use timeseries
      use spectra
      use eqpar
      implicit none
      integer                     :: i
      open(unit=33,file='FACCN.txt',status='unknown')
      write(33,'(a18)')'EVENT INFORMATION:'
      write(33,11)eqdate(1:3)
11    format('Event date:            ',i4.4,'/',i2.2,'/',i2.2)
      write(33,12)eqdate(4:6),eqmsecond
12    format('Event origon time:       ',i2.2,':',i2.2,':',i2.2,f4.3)
      write(33,13)eqcoord(1)
13    format('Epicenter latitude:    ',f8.4)
      write(33,14)eqcoord(2)
14    format('Epicenter longitude:   ',f9.4)
      write(33,15)eqcoord(3)
15    format('Hypocentral depth(km): ',f7.2)
      write(33,16)eqmag
16    format('Magnitude:             ',f5.2)
      write(33,17)staname, stdist
17    format('Distance from ',a4,' :   ',f8.2,1x,'km')
      write(33,'(a)')'|   Time(s)    |Accel.(cm/s^2)|Frequency (Hz)|  Sp
     1ec.Ampl.  | Spec.Amp.Smo |  Spec. Pha.  |'
      do i=1, npoint
           write(33,'(6(1x,g13.6,1x))') (real(i-1)/sr),acc(i),
     1                                  freq(i),fa(i),smoothfa(i),fp(i)
      enddo
      close(unit=33)
      return
      end
