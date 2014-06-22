      subroutine make_evedir()
      use datapar, only           :  SEEDfile, dirname, root, eve_path
      use traceinfo, only         :  doy
      use eqpar                
      implicit none
      integer                     :: i, num
      character (len=2)           :: c2(5)
      character (len=3)           :: c3
      character (len=4)           :: c4

      write(c4,'(i4.4)')eqdate(1)
c      call date2doy(eqdate(1),eqdate(2),eqdate(3),doy)
c      write(c3,'(i3.3)')doy
c      dirname='dir_'//c4//'.'//c3//'.'
      dirname=c4//'.'
      do i=2,6
           write(c2(i-1),'(i2.2)')eqdate(i)
      enddo
      do i=1,5
           dirname=trim(dirname)//c2(i)//'.'
      enddo 
c      dirname=trim(dirname)//'0000.'
      call serialn(num,1)
      num=mod(num,1000)
      write(c3,'(i3.3)')num
      dirname=trim(dirname)//c3
      call system('mkdir '//dirname)
      call getcwd(root)
      eve_path=trim(root)//'/'//trim(dirname)

      call system('cp -f '//trim(SEEDfile)//' '//trim(eve_path)//'/'
     1//trim(dirname)//'.SEED')

      return
      end
