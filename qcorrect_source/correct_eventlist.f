      subroutine correct_eventlist()
      use eventlistpar
      implicit none
      integer                     :: i, j
      real                        :: lon
      if (ieflag == 0) return     !Added on March 4
      do i=1,n_eventlist
c          read(eventlist(i)(116:122),'(f7.2)')lon
c          if(abs(lon) < 100.)then
           if(eventlist(i)(123:123) == ',')then
                do j=200,117,-1
                     eventlist(i)(j:j)=eventlist(i)(j-1:j-1)
                enddo
                eventlist(i)(116:116)=' '
           endif
           if(eventlist(i)(128:128) == 'g'.or.
     1        eventlist(i)(128:128) == '*') then
                do j=200,126,-1
                     eventlist(i)(j:j)=eventlist(i)(j-1:j-1)
                enddo
                eventlist(i)(125:125)=''
           endif
      enddo
      return
      end

