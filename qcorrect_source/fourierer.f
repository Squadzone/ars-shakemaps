      subroutine fourierer()
      use traceinfo
      use timeseries
      use spectra
      implicit none
      integer                     :: i
      do i=1,npoint
           fouriered(i)=cmplx(padded(i))
      enddo
      call fork(npoint,fouriered,-1.)
      do i=1,npoint
           four_amp(i)=cabs(fouriered(i))
      enddo
      return
      end
