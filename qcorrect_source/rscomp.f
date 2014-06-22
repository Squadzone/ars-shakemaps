c     calculates response spectrum from acceleration time history
c     damp is % critical damPIng. freq2 is maximum freq. to consider.

      subroutine rscomp(a,freqpsa,psa)
      use par
      use traceinfo
      implicit none
      integer                     :: k
      real                        :: PI, sd, frinc, beta
      real, dimension (1000)      :: freqpsa ,omega ,psa 
      real, dimension (npoint)    :: a
      PI=4.*atan(1.)
      if (iabs(nfreq) > 1000) then
           write (15,*)
           write (15,*) ' Nfreq cannot exceed 1000'
           return
      endif
c     Convert % damping to fraction
      beta=damp*0.01
c     Generate some logarithmically-spaced frequencies
      freqpsa(1)=freq1
      omega(1)=2.*PI*freqpsa(1)
      if (nfreq.ge.2) then
           frinc=alog(freq2/freq1)/(nfreq-1)
           do k=2,nfreq
                freqpsa(k)=freq1*exp((k-1)*frinc)
                omega(k)=2.*PI*freqpsa(k)
           enddo
      endif
c     Call new response spectrum routine for each desired freq
      do k=1,nfreq
           call sdcomp(a, npoint, omega(k), beta, 1/sr, sd)
           psa(k)=sd*omega(k)*omega(k)
      enddo 
      return
      end

