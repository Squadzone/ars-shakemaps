      function i_strcmp(str1,str2)
      implicit none
      integer i, n, i_strcmp
      character (len=*) :: str1, str2
      i_strcmp=-1
      n=len(str1)-len(str2)
      if(n < 0)return
      do i=1,n+1
          if(str1(i:i+len(str2)-1) == str2)then
          i_strcmp=i
          return
          endif
      enddo
      return
      end
