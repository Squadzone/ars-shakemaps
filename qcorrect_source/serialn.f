      subroutine serialn(num,i)
      implicit none
      integer :: new_num, num, i, is
      integer :: unitn=71
      character (len=20) :: filename='ren_eve.b'
      unitn=71
      filename='ren_eve.b'
      open(unit=unitn,file=filename,form='unformatted', iostat=is,
     *     status='old')
      if(is>0)then
         num=0
         write(*,*)'File ren_eve.b doesnot exist, default serial=0'
         open(unit=unitn,file=filename,form='unformatted',status='new')
         write(unitn)num
         rewind(unitn)
      end if
      read(unitn)num
c     write(*,*)num
      new_num=num+i
      rewind(unitn)
      write(unitn)new_num
      close(unitn)
      return
      end
