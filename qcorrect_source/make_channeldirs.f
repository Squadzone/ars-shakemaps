      subroutine make_channeldirs()
      use datapar
      implicit none
      integer                     :: i, is
      character (len=30)          :: tmpline
      character (len=1)           :: c1
      c1=char(39)
      call system('ls *RESP* > resp.lis')
c     call system('awk '//c1//'{print "      ",$0}'//'\''//
c    1            ' resp.lis > resps.lis')
      call system('awk '//c1//'{print "      ",$0}'//c1//
     1            ' resp.lis > resps.lis')
      call system('ls *SAC_ASC* > sac.lis')
      open(unit=76, file='resp.lis',status='old')
      nchannel=0
      is=0
      channels=''
      do while(is == 0)
           read(76,'(a)',iostat=is)tmpline
           if(is /= 0)cycle
           nchannel=nchannel+1
           channels(nchannel)=tmpline(6:)
      enddo
      close(unit=76)
      do while(len_trim(channels(nchannel)) == 0)
           nchannel=nchannel-1
      enddo
c      do i=1,nchannel
c           call system('mkdir '//trim(channels(i)))
c           chan_path=trim(eve_path)//'/'//trim(channels(i))
c           call system('mv -f RESP*'//trim(channels(i))//'* *'//
c     1        trim(channels(i))//'*SAC_ASC '//trim(chan_path))
c      enddo
      return
      end
