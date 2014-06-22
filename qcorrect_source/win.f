      subroutine win(i, nstart, nstop, ntaper, wind)
      implicit none
      integer                     :: i, nstart, nstop, ntaper
      real                        :: pi, wind, dum1, dum2
c     applies cosine tapered window.
c     unit amplitude assumed
c     written by D. M. Boore
c     latest revision: 9/26/95
      pi = 4.0 * atan(1.0)
      wind = 0.0
      if ( i < nstart .or. i >  nstop) return
      wind = 1.0
      if ( i >= nstart+ntaper .and. i <= nstop-ntaper ) return
      dum1 = real(nstop+nstart)/2.0
      dum2 = real(nstop-nstart-ntaper)/2.0
      wind = 0.5 * (1.0 - sin( pi*
     1             ( abs(real(i)-dum1) - dum2 ) /real(ntaper) ) )
      return
      end

