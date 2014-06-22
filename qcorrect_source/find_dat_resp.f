      subroutine find_dat_resp(channame,dat_file,resp_file)
      implicit none
      integer                     :: is
      character (len=50)          :: dat_file,resp_file
      character (len=30)          :: channame
c      call system('ls *SAC_ASC* > tmp.lis')
      call system('ls *'//trim(channame)//'*SAC_ASC* > tmp.lis')
      open(unit=1,file='tmp.lis',status='old')
      read(1,'(a)',iostat=is)dat_file
      if(is /= 0)dat_file=''
      close(unit=1)
      call system('rm -f tmp.lis')
c      call system('ls *RESP* > tmp.lis')
      call system('ls *RESP*'//trim(channame)//'* > tmp.lis')
      open(unit=1,file='tmp.lis',status='old')
      read(1,'(a)',iostat=is)resp_file
      if(is /= 0)resp_file=''
      close(unit=1)
      call system('rm -f tmp.lis')
      return
      end
