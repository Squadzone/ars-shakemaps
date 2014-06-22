      subroutine getinput()
      use datapar, only           :  SEEDfile
      use eqpar, only             :  eqdate, eqcoord, eqmag
      implicit none
      integer                     :: i
      character (len=50)          :: arg

      if(iargc() == 0)then
           write(*,*)'Enter the SEED file name: '
           read(*,*)SEEDfile
           call find_eqpar()
      elseif(iargc() == 1)then
           call getarg(1,SEEDfile)
           call find_eqpar()
      elseif(iargc() == 11)then
           call getarg(1,SEEDfile)
           do i=2,7
                arg=''
                call getarg(i,arg)
                read(arg,*)eqdate(i-1)
           enddo
           do i=8,10
                arg=''
                call getarg(i,arg)
                read(arg,*)eqcoord(i-7)
           enddo          
           arg=''
           call getarg(11,arg)
           read(arg,*)eqmag
      else
           write(*,*)'Improper number of arguments, bye.'
           call exit
      endif
      return
      end
