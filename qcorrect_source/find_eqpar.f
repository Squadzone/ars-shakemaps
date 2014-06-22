      subroutine find_eqpar()
      implicit none
      call read_eventlist()
      call correct_eventlist()
      call find_event()
      end
