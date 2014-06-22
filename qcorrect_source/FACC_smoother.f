      subroutine FACC_smoother()
      use traceinfo
      use spectra
      use par
      implicit none
      integer                     :: i, j, n
      real                        :: fl, fh, sums
      smoothfa=fa
      if(ismooth == 0)return
      do i=1,npoint,1
           n=0
           sums=0.
           fl=freq(i)-fbox
           fh=freq(i)+fbox
           do j=1,npoint,1
                if(freq(j) >= fl.and.freq(j) <= fh)then
                     if(abs(fa(j)) >= 0.0000001)then
                          sums=sums+log10(fa(j))
                          n=n+1
                     endif
                endif
           enddo
           if (n > 0)then
                smoothfa(i)=10.**(sums/float(n))
           endif
      enddo
      return
      end
