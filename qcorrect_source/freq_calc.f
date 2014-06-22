      subroutine freq_calc()
      use spectra
      use traceinfo
      implicit none
      integer                     :: i
      do i=1,npoint,1
           freq(i)=real(i-1)*sr/real(npoint)
      enddo
      return
      end

