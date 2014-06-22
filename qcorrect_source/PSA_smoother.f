      subroutine PSA_smoother(freqpsa,psa,smooth)
      use par
      implicit none
      integer                     :: i, j, n
      real                        :: sum_box, fl, fh 
      real, dimension (1000)      :: freqpsa ,psa ,smooth
      if(ismooth == 0)then
           smooth=psa
           return
      endif
      do i=1,nfreq,1
           n=0
           sum_box=0.
           fl=freqpsa(i)-fbox
           fh=freqpsa(i)+fbox
           do j=1,nfreq,1
                if(freqpsa(j) >= fl.and.freqpsa(j) <= fh)then
                     sum_box=sum_box+psa(j)
                     n=n+1
                endif
           enddo
           smooth(i)=sum_box/real(n)
      enddo
      return
      end
 
