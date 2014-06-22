      subroutine merge_all()
      implicit none
      integer                     :: i, is, n_sta
      character (len=50)          :: nam, name_part(10000)
      is=0
      n_sta=0
      name_part(10000)=''
      call system('ls *SAC_ASC | sort -k1.24 | uniq -s 23 > SAC.lis')
      open(unit=85,file='SAC.lis',status='old')
      do while (is==0)
           n_sta=n_sta+1
           read(85,'(23x,a)',iostat=is)name_part(n_sta)
           if(is /= 0)then
                name_part(n_sta)=''
                n_sta=n_sta-1
           endif
      enddo
      close(unit=85)
      do while (len_trim(name_part(n_sta))==0)
           n_sta=n_sta-1
      enddo
      call system('rm -f SAC.lis')
      do i=1,n_sta
           nam=name_part(i)
           call merge_traces(nam)
      enddo

      return
      end
