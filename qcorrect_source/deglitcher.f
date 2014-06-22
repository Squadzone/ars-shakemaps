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
      implicit none
      integer                     :: npts, iglit
      integer                     :: j, jj, jstop, iflag, nspike
      real                        :: runavg, spike
      real, dimension (1000000)   :: x
c
c     Check if glithch removal is requested by user
c
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
c     write(*,*)'Starting glitch removal'
      nspike = 1
      do while (nspike > 0)
           nspike= 0
c          write(*,*)'Looking for Spikes'
           do j=11,npts-10
                runavg=0
                do jj=-10, 10
                     if(x(j+jj) /= 0.)then
                          runavg=runavg+alog10(abs(x(j+jj)))/21.
                     endif
                enddo
                spike=10.*10.**runavg
                if(abs(x(j)) > spike) then
                     nspike = nspike + 1
                     x(j) = (x(j-1) + x(j+1))/2.
                     if(abs(x(j)) > spike)then
                          x(j) = (x(j-2) + x(j+2))/2.
                          if(abs(x(j)) > spike) x(j) = 1.
                     endif
                endif
           enddo 
      enddo
      return
      end
