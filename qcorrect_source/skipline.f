      subroutine skipline(num_unit, num_lines)
      implicit none
      integer num_unit, num_lines, i
      if(num_lines<1)return
      do i=1,num_lines,1
           read(num_unit,*)
      enddo
      return
      end
