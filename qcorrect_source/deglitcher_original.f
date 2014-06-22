      subroutine deglitcher(x,npts,iglit)
c
c     Removes glitches from array x and makes corresponding
c     correction to valmax.
c     Anything >10* the (log) avg of a running 20-pt. amplitude 
c     average is assumed to be a glitch.  Replaced with avg of 
c     neighbour values.
c     Constant amplitude steps (more than 20 identical values
c     in a row) are assumed to be glitches.  Replaced with 0
c
c     G.M. Atkinson, Oct. 1990
c     Revised Aug. 1991
c
      integer                     :: npts, iglit
      integer                     :: j, jj, jstop, iflag, ntotal, nspike
      real                        :: runavg, spike
      real, dimension (1000000)   :: x
c     valmax = 0.
c
c     Check if glithch removal is requested by user
      if(iglit /= 1) return

c     First remove constant amplitude steps.
c     If next 20 values are exactly the same as this one,
c     we assume its an erroneous step.
c
      jstop = 0
      do j=1,npts-20
           iflag = 1
           do jj = 1, 20
                if(x(j+jj) /=  x(j)) iflag = 0
           enddo
           if (iflag == 1) then
c               This is a step.
                jstop = j + 20
           endif
           if (jstop >= j) x(j) = x(j+20)
      enddo
c     write(*,*)'Finished looking for a Long Glitch'
c
      ntotal = 0
49    continue
c     write(*,*)'Starting glitch removal'
      runavg = 0.
      nspike = 0
c     write(*,*)'Calculating Run Average'
      do jj = 1,21
          if(x(jj) ==  0.) x(jj)=1.
          runavg = runavg + alog10(abs(x(jj)))
      enddo
      runavg=runavg/21.
c     write(*,*)'Looking for Spikes'
      do j=11,npts-11
           if(x(j-10) == 0.) x(j-10)=1.
           if(x(j+11) == 0.) x(j+11)=1.
           runavg =runavg - alog10(abs(x(j-10)))/21.
     1                    + alog10(abs(x(j+11)))/21.
           spike = 10.* 10.**runavg
           if(abs(x(j)) > spike) then
                nspike = nspike + 1
                x(j) = (x(j-1) + x(j+1))/2.
                if(abs(x(j)) > spike)then
                     x(j) = (x(j-2) + x(j+2))/2.
                     if(abs(x(j)) > spike) x(j) = 1.
                endif
           endif
c          if(abs(x(j)) > valmax) valmax = abs(x(j))
      enddo 
      ntotal = ntotal + nspike
      if (nspike > 1) go to 49
      return
      end
