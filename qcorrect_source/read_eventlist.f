      subroutine read_eventlist()
      use par
      use eventlistpar
      implicit none
      integer                     :: is
      is=0
      ieflag=1
      eventlist=''
      n_eventlist=0
      open(unit=41,file=elist,iostat=is,status='old')
      if(is /= 0)then
           ieflag=0
           return
      endif
      call skipline(41,2)
      do while (is == 0)
           n_eventlist=n_eventlist+1
           read(41,'(a180)',iostat=is)eventlist(n_eventlist)
           if(is /= 0)then
                eventlist(n_eventlist)=''
                n_eventlist=n_eventlist-1
           endif
      enddo
      close(unit=41)
      do while (len_trim(eventlist(n_eventlist)) < 50)
           n_eventlist=n_eventlist-1
      enddo
      call correct_eventlist(eventlist,n_eventlist)
      return
      end
